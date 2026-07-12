#!/usr/bin/env elixir
# docket.exs — personal work-item tracker: runtime-loaded FSMs + append-only event log.

defmodule Docket.Machine do
  @moduledoc "Parses Mermaid stateDiagram-v2 machine definitions."

  @edge ~r/^(\S+)\s+-->\s+(\S+)(\s*:.*)?$/

  def parse(text, name) do
    text
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.reduce_while({:ok, {[], nil}}, fn {raw, n}, {:ok, {edges, cycle}} ->
      case classify(String.trim(raw)) do
        :skip -> {:cont, {:ok, {edges, cycle}}}
        {:edge, from, to} -> {:cont, {:ok, {[{from, to} | edges], cycle}}}
        {:cycle, from, to} -> {:cont, {:ok, {edges, {from, to}}}}
        :error -> {:halt, {:error, "line #{n}: cannot parse #{inspect(String.trim(raw))}"}}
      end
    end)
    |> case do
      {:ok, {edges, cycle}} -> build(name, Enum.reverse(edges), cycle)
      {:error, msg} -> {:error, msg}
    end
  end

  def validate_move(machine, from, to) do
    cond do
      to not in machine.states ->
        {:error, "unknown state #{inspect(to)}; states: #{Enum.join(machine.states, ", ")}"}

      to in Map.get(machine.transitions, from, []) ->
        :ok

      true ->
        allowed = machine.transitions |> Map.get(from, []) |> Enum.join(", ")
        {:error, "illegal transition #{from} -> #{to}; from #{from} you can go to: #{allowed}"}
    end
  end

  defp classify(""), do: :skip
  defp classify("stateDiagram" <> _), do: :skip

  defp classify("%%" <> rest) do
    case Regex.run(~r/^\s*cycle:\s*(\S+)\s+-->\s+(\S+)\s*$/, rest) do
      [_, from, to] -> {:cycle, from, to}
      nil -> :skip
    end
  end

  defp classify(line) do
    case Regex.run(@edge, line) do
      [_, from, to | _label] -> {:edge, from, to}
      nil -> :error
    end
  end

  defp build(name, edges, cycle) do
    states =
      edges
      |> Enum.flat_map(fn {from, to} -> [from, to] end)
      |> Enum.uniq()
      |> Enum.reject(&(&1 == "[*]"))

    transitions =
      Map.new(states, fn s ->
        {s, for({from, to} <- edges, from == s, to != "[*]", do: to)}
      end)

    initials = for {"[*]", to} <- edges, do: to
    terminals = for {from, "[*]"} <- edges, do: from

    if initials == [] do
      {:error, "no initial state; add a \"[*] --> <state>\" line"}
    else
      {:ok,
       %{
         name: name,
         states: states,
         transitions: transitions,
         initials: initials,
         terminals: terminals,
         cycle: cycle,
         warnings: warnings(states, transitions, initials, terminals, cycle)
       }}
    end
  end

  defp warnings(states, transitions, initials, terminals, cycle) do
    reachable = reach(initials, transitions, MapSet.new(initials))

    unreachable =
      for s <- states, s not in reachable do
        "state #{inspect(s)} is unreachable from any initial state"
      end

    no_terminal =
      if terminals == [], do: ["no terminal state; add a \"<state> --> [*]\" line"], else: []

    bad_cycle =
      case cycle do
        nil ->
          []

        {from, to} ->
          for s <- [from, to], s not in states do
            "cycle directive names unknown state #{inspect(s)}"
          end
      end

    unreachable ++ no_terminal ++ bad_cycle
  end

  defp reach([], _transitions, seen), do: seen

  defp reach([s | rest], transitions, seen) do
    next = for t <- Map.get(transitions, s, []), t not in seen, do: t
    reach(next ++ rest, transitions, MapSet.union(seen, MapSet.new(next)))
  end
end

defmodule Docket.Store do
  @moduledoc "Append-only JSONL event log plus machine definitions, one directory."

  defmodule LogError do
    defexception [:message]
  end

  @event_keys %{
    "ts" => :ts,
    "id" => :id,
    "type" => :type,
    "title" => :title,
    "machine" => :machine,
    "state" => :state,
    "reason" => :reason
  }
  @event_types %{
    "created" => :created,
    "moved" => :moved,
    "blocked" => :blocked,
    "unblocked" => :unblocked
  }
  @required_fields %{
    created: [:title, :machine, :state],
    moved: [:state],
    blocked: [:reason],
    unblocked: []
  }

  def dir do
    System.get_env("DOCKET_DIR") ||
      case System.get_env("XDG_DATA_HOME") do
        nil -> Path.expand("~/.local/share/docket")
        xdg -> Path.join(xdg, "docket")
      end
  end

  def events_file, do: Path.join(dir(), "events.jsonl")

  def append(event) do
    File.mkdir_p!(dir())
    ts = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()
    line = event |> Map.put(:ts, ts) |> JSON.encode!()
    File.write!(events_file(), line <> "\n", [:append])
  end

  def events do
    case File.read(events_file()) do
      {:error, :enoent} ->
        []

      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.with_index(1)
        |> Enum.map(&decode_event/1)

      {:error, reason} ->
        raise LogError, "cannot read #{events_file()}: #{:file.format_error(reason)}"
    end
  end

  def next_id do
    events() |> Enum.map(& &1.id) |> Enum.max(fn -> 0 end) |> Kernel.+(1)
  end

  defp decode_event({line, n}) do
    case JSON.decode(line) do
      {:ok, raw} when is_map(raw) -> cast_event(raw, n)
      _ -> log_error(n, "not a JSON object")
    end
  end

  defp cast_event(raw, n) do
    event =
      Map.new(raw, fn {key, value} ->
        case @event_keys[key] do
          nil -> log_error(n, "unknown field #{inspect(key)}")
          atom -> {atom, value}
        end
      end)

    type = @event_types[event[:type]]

    cond do
      not is_integer(event[:id]) -> log_error(n, "id must be an integer")
      is_nil(type) -> log_error(n, "unknown event type #{inspect(event[:type])}")
      true -> validate_fields(%{event | type: type}, n)
    end
  end

  defp validate_fields(event, n) do
    missing = Enum.find([:ts | @required_fields[event.type]], &(not is_binary(event[&1])))

    cond do
      missing ->
        log_error(n, "#{event.type} event needs a #{missing} string")

      match?({:error, _}, DateTime.from_iso8601(event.ts)) ->
        log_error(n, "bad timestamp #{inspect(event.ts)}")

      true ->
        event
    end
  end

  defp log_error(n, reason), do: raise(LogError, "events.jsonl line #{n}: #{reason}")
end

defmodule Docket.Machines do
  @moduledoc "Registry of machine definitions: machines/*.mmd, name = basename."

  def dir, do: Path.join(Docket.Store.dir(), "machines")

  def names do
    dir()
    |> Path.join("*.mmd")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".mmd"))
    |> Enum.sort()
  end

  def path(name), do: Path.join(dir(), "#{name}.mmd")

  def get(name) do
    case File.read(path(name)) do
      {:ok, text} ->
        text |> Docket.Machine.parse(name) |> report_warnings()

      {:error, :enoent} ->
        case names() do
          [] -> {:error, no_machines()}
          names -> {:error, "no machine #{inspect(name)}; available: #{Enum.join(names, ", ")}"}
        end

      {:error, reason} ->
        {:error, "cannot read #{path(name)}: #{:file.format_error(reason)}"}
    end
  end

  def no_machines do
    String.trim_trailing("""
    no machines; create #{path("<name>")} like:

      stateDiagram-v2
        [*] --> todo
        todo --> done
        done --> [*]
    """)
  end

  defp report_warnings({:ok, machine} = result) do
    Enum.each(machine.warnings, &IO.puts(:stderr, "warning: #{machine.name}: #{&1}"))
    result
  end

  defp report_warnings(error), do: error
end

defmodule Docket.Items do
  @moduledoc "Projection: fold the event log into current item state."

  def all do
    Docket.Store.events()
    |> Enum.group_by(& &1.id)
    |> Map.new(fn {id, evs} -> {id, build(id, evs)} end)
  end

  defp build(id, evs) do
    base = %{id: id, title: "(untitled)", machine: nil, state: nil, blocked: nil, history: []}

    evs
    |> Enum.reduce(base, fn ev, item ->
      case ev.type do
        :created ->
          %{
            item
            | title: ev.title,
              machine: ev.machine,
              state: ev.state,
              history: [{ev.ts, ev.state} | item.history]
          }

        :moved ->
          %{item | state: ev.state, history: [{ev.ts, ev.state} | item.history]}

        :blocked ->
          %{item | blocked: ev.reason}

        :unblocked ->
          %{item | blocked: nil}
      end
    end)
    |> Map.update!(:history, &Enum.reverse/1)
  end
end

defmodule Docket.CLI do
  @moduledoc "Command dispatch. Every command returns an exit code."

  alias Docket.{Machines, Store}

  def main(argv) do
    case argv do
      ["new" | rest] when rest != [] -> new(rest)
      ["move", id, state] -> with_id(id, &move(&1, state))
      ["list" | rest] -> list(rest)
      ["show", id] -> with_id(id, &show/1)
      ["block", id | reason] when reason != [] -> with_id(id, &block(&1, Enum.join(reason, " ")))
      ["unblock", id] -> with_id(id, &unblock/1)
      ["graph"] -> registry()
      ["graph", name] -> graph(name)
      ["stats"] -> stats()
      _ -> usage()
    end
  rescue
    e in Store.LogError -> fail(Exception.message(e))
  end

  defp stats do
    items = Map.values(Docket.Items.all())

    case load_machines(items) do
      {:error, msg} ->
        fail(msg)

      {:ok, machines} ->
        items
        |> Enum.group_by(& &1.machine)
        |> Enum.sort_by(&elem(&1, 0))
        |> case do
          [] ->
            IO.puts("no items yet")

          groups ->
            Enum.each(groups, fn {name, group} ->
              if length(groups) > 1, do: IO.puts(name)
              machine_stats(group, machines[name])
            end)
        end

        0
    end
  end

  defp machine_stats(items, machine) do
    intervals = Enum.flat_map(items, &item_intervals(&1, machine))

    machine.states
    |> Enum.map(fn state -> {state, for({s, d} <- intervals, s == state, do: d)} end)
    |> Enum.reject(fn {_state, days} -> days == [] end)
    |> Enum.each(fn {state, days} ->
      IO.puts(
        "  #{String.pad_trailing(state, 10)} #{avg(days)}d avg over #{length(days)} stay(s)"
      )
    end)

    cycle_stats(items, machine)
  end

  defp item_intervals(item, machine) do
    stamped = for {ts, state} <- item.history, do: {timestamp(ts), state}

    closed =
      stamped
      |> Enum.zip(Enum.drop(stamped, 1))
      |> Enum.map(fn {{from_dt, state}, {to_dt, _}} -> {state, days_between(from_dt, to_dt)} end)

    {dt, state} = List.last(stamped)

    if state in machine.terminals do
      closed
    else
      closed ++ [{state, days_between(dt, DateTime.utc_now())}]
    end
  end

  defp cycle_stats(_items, %{cycle: nil}), do: :ok

  defp cycle_stats(items, %{cycle: {from, to}}) do
    durations =
      for item <- items,
          start_dt = first_entered(item, from),
          done_dt = first_entered(item, to),
          do: days_between(start_dt, done_dt)

    if durations != [] do
      IO.puts(
        "  cycle time (#{from} -> #{to}): #{avg(durations)}d avg over #{length(durations)} item(s)"
      )
    end

    :ok
  end

  defp avg(values), do: Float.round(Enum.sum(values) / length(values), 1)

  defp first_entered(item, state) do
    case Enum.find(item.history, fn {_ts, s} -> s == state end) do
      {ts, _} -> timestamp(ts)
      nil -> nil
    end
  end

  defp timestamp(ts) do
    {:ok, dt, _offset} = DateTime.from_iso8601(ts)
    dt
  end

  defp days_between(from_dt, to_dt), do: DateTime.diff(to_dt, from_dt, :second) / 86_400

  defp registry do
    items = Map.values(Docket.Items.all())

    Enum.each(Machines.names(), fn name ->
      case Machines.get(name) do
        {:ok, m} ->
          count = Enum.count(items, &(&1.machine == name))
          plural = if count == 1, do: "", else: "s"

          IO.puts(
            "#{name}  #{length(m.states)} states  #{count} item#{plural}  #{Machines.path(name)}"
          )

        {:error, msg} ->
          IO.puts("#{name}  INVALID: #{msg}")
      end
    end)

    0
  end

  defp graph(name) do
    case Machines.get(name) do
      {:ok, _machine} ->
        IO.write(File.read!(Machines.path(name)))
        0

      {:error, msg} ->
        fail(msg)
    end
  end

  defp show(id) do
    with_item(id, fn item ->
      blocked = if item.blocked, do: ", BLOCKED: #{item.blocked}", else: ""
      IO.puts("##{item.id} #{item.title}  (#{item.machine}: #{item.state}#{blocked})")
      Enum.each(item.history, fn {ts, state} -> IO.puts("  #{ts}  -> #{state}") end)
      0
    end)
  end

  defp block(id, reason) do
    with_item(id, fn _item ->
      Store.append(%{id: id, type: :blocked, reason: reason})
      IO.puts("##{id} blocked: #{reason}")
      0
    end)
  end

  defp unblock(id) do
    with_item(id, fn _item ->
      Store.append(%{id: id, type: :unblocked})
      IO.puts("##{id} unblocked")
      0
    end)
  end

  defp with_item(id, fun) do
    case fetch_item(id) do
      {:ok, item} -> fun.(item)
      {:error, msg} -> fail(msg)
    end
  end

  defp list(rest) do
    case parse_opts(rest, strict: [all: :boolean, machine: :string], aliases: [m: :machine]) do
      {:ok, opts, []} ->
        items =
          Docket.Items.all()
          |> Map.values()
          |> Enum.filter(fn i -> opts[:machine] in [nil, i.machine] end)

        render_list(items, opts)

      {:ok, _opts, words} ->
        fail("unexpected argument: #{Enum.join(words, " ")}")

      {:error, msg} ->
        fail(msg)
    end
  end

  defp render_list(items, opts) do
    case load_machines(items) do
      {:error, msg} ->
        fail(msg)

      {:ok, machines} ->
        items
        |> Enum.reject(fn i ->
          !opts[:all] and i.state in machines[i.machine].terminals
        end)
        |> Enum.group_by(& &1.machine)
        |> Enum.sort_by(&elem(&1, 0))
        |> case do
          [] ->
            IO.puts("nothing here")

          groups ->
            groups
            |> Enum.map(fn {name, group} ->
              rows =
                group
                |> Enum.sort_by(fn i -> {state_order(machines[name], i.state), i.id} end)
                |> Enum.map(&row/1)

              if length(groups) > 1, do: [name | rows], else: rows
            end)
            |> Enum.intersperse([""])
            |> List.flatten()
            |> Enum.each(&IO.puts/1)
        end

        0
    end
  end

  defp load_machines(items) do
    items
    |> Enum.map(& &1.machine)
    |> Enum.uniq()
    |> Enum.reduce_while({:ok, %{}}, fn name, {:ok, acc} ->
      case Machines.get(name) do
        {:ok, machine} -> {:cont, {:ok, Map.put(acc, name, machine)}}
        {:error, msg} -> {:halt, {:error, msg}}
      end
    end)
  end

  defp state_order(machine, state),
    do: Enum.find_index(machine.states, &(&1 == state)) || length(machine.states)

  defp row(item) do
    flag = if item.blocked, do: "  [BLOCKED: #{item.blocked}]", else: ""

    String.pad_leading("##{item.id}", 4) <>
      "  " <>
      String.pad_trailing(item.state, 10) <>
      String.pad_leading("#{days_in_state(item)}d", 4) <> "  " <> item.title <> flag
  end

  defp days_in_state(item) do
    {ts, _state} = List.last(item.history)

    case DateTime.from_iso8601(ts) do
      {:ok, dt, _} -> DateTime.utc_now() |> DateTime.diff(dt, :second) |> div(86_400)
      _ -> 0
    end
  end

  defp move(id, state) do
    with {:ok, item} <- fetch_item(id),
         {:ok, machine} <- Machines.get(item.machine),
         :ok <- Docket.Machine.validate_move(machine, item.state, state) do
      Store.append(%{id: id, type: :moved, state: state})
      IO.puts("##{id} #{item.state} -> #{state}  (#{item.title})")
      0
    else
      {:error, msg} -> fail(msg)
    end
  end

  defp fetch_item(id) do
    case Docket.Items.all()[id] do
      nil -> {:error, "no item ##{id}"}
      item -> {:ok, item}
    end
  end

  defp parse_opts(rest, parser_opts) do
    case OptionParser.parse(rest, parser_opts) do
      {opts, words, []} ->
        {:ok, opts, words}

      {_opts, _words, invalid} ->
        {:error, "unknown option: #{invalid |> Enum.map(&elem(&1, 0)) |> Enum.join(", ")}"}
    end
  end

  defp with_id(s, fun) do
    case parse_id(s) do
      {:ok, id} -> fun.(id)
      {:error, msg} -> fail(msg)
    end
  end

  defp parse_id("#" <> rest), do: parse_id(rest)

  defp parse_id(s) do
    case Integer.parse(s) do
      {id, ""} -> {:ok, id}
      _ -> {:error, "not an item id: #{inspect(s)}"}
    end
  end

  defp new(rest) do
    with {:ok, opts, words} <-
           parse_opts(rest,
             strict: [machine: :string, state: :string],
             aliases: [m: :machine, s: :state]
           ),
         {:ok, title} <- require_title(words),
         {:ok, machine} <- resolve_machine(opts[:machine]),
         {:ok, state} <- resolve_entry(machine, opts[:state]) do
      id = Store.next_id()
      Store.append(%{id: id, type: :created, title: title, machine: machine.name, state: state})
      IO.puts("##{id} [#{machine.name}/#{state}] #{title}")
      0
    else
      {:error, msg} -> fail(msg)
    end
  end

  defp require_title([]), do: {:error, "a title is required"}
  defp require_title(words), do: {:ok, Enum.join(words, " ")}

  defp resolve_machine(nil) do
    case Machines.names() do
      [] -> {:error, Machines.no_machines()}
      [sole] -> Machines.get(sole)
      names -> {:error, "multiple machines; pick one with -m: #{Enum.join(names, ", ")}"}
    end
  end

  defp resolve_machine(name), do: Machines.get(name)

  defp resolve_entry(machine, nil), do: {:ok, hd(machine.initials)}

  defp resolve_entry(machine, state) do
    if state in machine.initials do
      {:ok, state}
    else
      {:error,
       "#{inspect(state)} is not an entry point; initials: #{Enum.join(machine.initials, ", ")}"}
    end
  end

  defp fail(msg) do
    IO.puts(:stderr, "error: #{msg}")
    1
  end

  defp usage do
    IO.puts(:stderr, """
    docket — personal work-item tracker
      new <title> [-m machine] [-s state] | move <id> <state> | list [--all] [-m machine]
      show <id> | block <id> <reason> | unblock <id> | stats | graph [machine]
    """)

    1
  end
end

unless System.get_env("DOCKET_NO_MAIN") do
  System.halt(Docket.CLI.main(System.argv()))
end
