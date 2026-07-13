System.put_env("DOCKET_NO_MAIN", "1")
Code.require_file("docket.exs", __DIR__)
ExUnit.start()

defmodule DocketTest.Env do
  import ExUnit.Callbacks

  def isolate(_context) do
    original = System.get_env("DOCKET_DIR")
    dir = Path.join(System.tmp_dir!(), "docket-test-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    System.put_env("DOCKET_DIR", dir)

    on_exit(fn ->
      File.rm_rf!(dir)

      if original,
        do: System.put_env("DOCKET_DIR", original),
        else: System.delete_env("DOCKET_DIR")
    end)

    {:ok, dir: dir}
  end

  def write_machine(dir, name, text) do
    machines = Path.join(dir, "machines")
    File.mkdir_p!(machines)
    File.write!(Path.join(machines, "#{name}.mmd"), text)
  end

  def write_sdlc(dir) do
    write_machine(dir, "sdlc", """
    stateDiagram-v2
      %% cycle: doing --> shipped
      [*] --> idea
      idea --> shaped
      shaped --> doing
      doing --> review
      review --> shipped
      idea --> dropped
      shipped --> [*]
      dropped --> [*]
    """)
  end
end

defmodule Docket.MachineTest do
  use ExUnit.Case

  test "parse/2 extracts transitions, including states with no exits" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          [*] --> a
          a --> b
          b --> [*]
        """,
        "test"
      )

    assert m.transitions == %{"a" => ["b"], "b" => []}
  end

  test "parse/2 collects initial states in declaration order" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          [*] --> triage
          [*] --> doing
          triage --> doing
          doing --> [*]
        """,
        "test"
      )

    assert m.initials == ["triage", "doing"]
  end

  test "parse/2 collects terminal states" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          [*] --> a
          a --> shipped
          a --> dropped
          shipped --> [*]
          dropped --> [*]
        """,
        "test"
      )

    assert m.terminals == ["shipped", "dropped"]
  end

  test "parse/2 records states in declaration order and keeps the machine name" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          [*] --> idea
          idea --> doing
          doing --> shipped
          idea --> dropped
          shipped --> [*]
        """,
        "sdlc"
      )

    assert m.states == ["idea", "doing", "shipped", "dropped"]
    assert m.name == "sdlc"
  end

  test "parse/2 rejects unparseable lines with the line number" do
    assert {:error, msg} =
             Docket.Machine.parse(
               """
               stateDiagram-v2
                 [*] --> a
                 a -> b
               """,
               "test"
             )

    assert msg =~ "line 3"
    assert msg =~ "a -> b"
  end

  test "parse/2 accepts and ignores transition labels" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          [*] --> a
          a --> b : kicked back
        """,
        "test"
      )

    assert m.transitions["a"] == ["b"]
  end

  test "parse/2 reads the cycle directive from a comment, defaulting to nil" do
    with_directive = """
    stateDiagram-v2
      %% cycle: a --> b
      [*] --> a
      a --> b
    """

    without_directive = """
    stateDiagram-v2
      %% just a comment
      [*] --> a
      a --> b
    """

    assert {:ok, %{cycle: {"a", "b"}}} = Docket.Machine.parse(with_directive, "test")
    assert {:ok, %{cycle: nil}} = Docket.Machine.parse(without_directive, "test")
  end

  test "parse/2 rejects a machine with no initial state" do
    assert {:error, msg} = Docket.Machine.parse("stateDiagram-v2\n  a --> b\n", "test")
    assert msg =~ "no initial state"
  end

  test "parse/2 warns about states unreachable from any initial" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          [*] --> a
          a --> b
          orphan --> b
          b --> [*]
        """,
        "test"
      )

    assert Enum.any?(m.warnings, &(&1 =~ "unreachable" and &1 =~ "orphan"))
  end

  test "parse/2 warns when the machine has no terminal state" do
    {:ok, m} = Docket.Machine.parse("stateDiagram-v2\n  [*] --> a\n  a --> b\n", "test")

    assert Enum.any?(m.warnings, &(&1 =~ "no terminal state"))
  end

  test "parse/2 warns when the cycle directive names unknown states" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          %% cycle: doing --> shipped
          [*] --> a
          a --> b
          b --> [*]
        """,
        "test"
      )

    assert Enum.any?(m.warnings, &(&1 =~ "cycle directive" and &1 =~ "doing"))
  end

  test "validate_move/3 allows legal transitions and rejects illegal or unknown ones" do
    {:ok, m} =
      Docket.Machine.parse(
        """
        stateDiagram-v2
          [*] --> idea
          idea --> doing
          doing --> shipped
          shipped --> [*]
        """,
        "test"
      )

    assert :ok = Docket.Machine.validate_move(m, "idea", "doing")

    assert {:error, msg} = Docket.Machine.validate_move(m, "idea", "shipped")
    assert msg =~ "idea -> shipped"
    assert msg =~ "doing"

    assert {:error, msg} = Docket.Machine.validate_move(m, "idea", "bogus")
    assert msg =~ "unknown state"
  end
end

defmodule Docket.StoreTest do
  use ExUnit.Case

  setup do
    original = {System.get_env("DOCKET_DIR"), System.get_env("XDG_DATA_HOME")}

    on_exit(fn ->
      {docket, xdg} = original
      if docket, do: System.put_env("DOCKET_DIR", docket), else: System.delete_env("DOCKET_DIR")
      if xdg, do: System.put_env("XDG_DATA_HOME", xdg), else: System.delete_env("XDG_DATA_HOME")
    end)

    :ok
  end

  test "dir/0 prefers DOCKET_DIR, then XDG_DATA_HOME/docket, then ~/.local/share/docket" do
    System.put_env("DOCKET_DIR", "/custom/place")
    System.put_env("XDG_DATA_HOME", "/xdg/data")
    assert Docket.Store.dir() == "/custom/place"

    System.delete_env("DOCKET_DIR")
    assert Docket.Store.dir() == "/xdg/data/docket"

    System.delete_env("XDG_DATA_HOME")
    assert Docket.Store.dir() == Path.expand("~/.local/share/docket")
  end

  test "append/1 and events/0 roundtrip events through JSONL without losing whitespace" do
    System.put_env("DOCKET_DIR", tmp_dir!())

    assert Docket.Store.events() == []

    Docket.Store.append(%{
      id: 1,
      type: :created,
      title: "tabs\tsurvive",
      machine: "sdlc",
      state: "idea"
    })

    Docket.Store.append(%{id: 1, type: :moved, state: "doing"})

    assert [created, moved] = Docket.Store.events()

    assert %{id: 1, type: :created, title: "tabs\tsurvive", machine: "sdlc", state: "idea"} =
             created

    assert %{id: 1, type: :moved, state: "doing"} = moved
    assert is_binary(created.ts)
  end

  test "append/1 and events/0 roundtrip a linked event" do
    System.put_env("DOCKET_DIR", tmp_dir!())

    Docket.Store.append(%{id: 1, type: :linked, ref: "INS-451"})

    assert [%{id: 1, type: :linked, ref: "INS-451"}] = Docket.Store.events()
  end

  test "next_id/0 starts at 1 and increments past the highest id" do
    System.put_env("DOCKET_DIR", tmp_dir!())

    assert Docket.Store.next_id() == 1

    Docket.Store.append(%{id: 1, type: :created, title: "a", machine: "m", state: "s"})
    Docket.Store.append(%{id: 7, type: :created, title: "b", machine: "m", state: "s"})

    assert Docket.Store.next_id() == 8
  end

  defp tmp_dir! do
    dir = Path.join(System.tmp_dir!(), "docket-test-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end
end

defmodule Docket.MachinesTest do
  use ExUnit.Case

  setup {DocketTest.Env, :isolate}

  test "get/1 loads a machine from machines/<name>.mmd", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "bugs", """
    stateDiagram-v2
      [*] --> triage
      triage --> fixed
      fixed --> [*]
    """)

    assert {:ok, m} = Docket.Machines.get("bugs")
    assert m.name == "bugs"
    assert m.states == ["triage", "fixed"]
  end

  test "get/1 reports an unknown machine", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "bugs", "stateDiagram-v2\n  [*] --> a\n  a --> [*]\n")

    assert {:error, msg} = Docket.Machines.get("nope")
    assert msg =~ "no machine"
    assert msg =~ "bugs"
  end
end

defmodule Docket.ItemsTest do
  use ExUnit.Case

  setup {DocketTest.Env, :isolate}

  test "all/0 folds a created event into an item" do
    Docket.Store.append(%{id: 1, type: :created, title: "thing", machine: "sdlc", state: "idea"})

    assert %{1 => item} = Docket.Items.all()
    assert item.title == "thing"
    assert item.machine == "sdlc"
    assert item.state == "idea"
    assert item.blocked == nil
    assert [{_ts, "idea"}] = item.history
  end

  test "all/0 folds moved, blocked, and unblocked events" do
    Docket.Store.append(%{id: 1, type: :created, title: "thing", machine: "sdlc", state: "idea"})
    Docket.Store.append(%{id: 1, type: :moved, state: "doing"})
    Docket.Store.append(%{id: 1, type: :blocked, reason: "waiting on review"})

    assert %{1 => item} = Docket.Items.all()
    assert item.state == "doing"
    assert item.blocked == "waiting on review"
    assert [{_, "idea"}, {_, "doing"}] = item.history

    Docket.Store.append(%{id: 1, type: :unblocked})

    assert %{1 => %{blocked: nil}} = Docket.Items.all()
  end

  test "all/0 folds linked events with the latest ref winning" do
    Docket.Store.append(%{id: 1, type: :created, title: "thing", machine: "sdlc", state: "idea"})

    assert %{1 => %{ref: nil}} = Docket.Items.all()

    Docket.Store.append(%{id: 1, type: :linked, ref: "INS-451"})
    Docket.Store.append(%{id: 1, type: :linked, ref: "INS-452"})

    assert %{1 => %{ref: "INS-452"}} = Docket.Items.all()
  end
end

defmodule Docket.CLITest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  setup {DocketTest.Env, :isolate}

  test "new creates an item in the sole machine's first initial", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    out = capture_io(fn -> assert Docket.CLI.main(["new", "ship", "the", "thing"]) == 0 end)

    assert out =~ "#1 [sdlc/idea] ship the thing"

    assert [%{type: :created, title: "ship the thing", machine: "sdlc", state: "idea"}] =
             Docket.Store.events()
  end

  test "new with an empty registry explains how to create a machine", %{dir: dir} do
    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["new", "x"]) == 1 end)

    assert err =~ "no machines"
    assert err =~ Path.join(dir, "machines")
    assert err =~ "stateDiagram-v2"
    assert Docket.Store.events() == []
  end

  test "naming a machine on an empty registry also explains how to create one", %{dir: dir} do
    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["new", "x", "-m", "sdlc"]) == 1 end)
    assert err =~ "no machines"
    assert err =~ Path.join(dir, "machines")

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["graph", "sdlc"]) == 1 end)
    assert err =~ "no machines"
  end

  test "new requires -m among several machines and restricts -s to entry points", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "bugs", """
    stateDiagram-v2
      [*] --> triage
      [*] --> hotfix
      triage --> fixed
      hotfix --> fixed
      fixed --> [*]
    """)

    DocketTest.Env.write_machine(dir, "work", "stateDiagram-v2\n  [*] --> idea\n  idea --> [*]\n")

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["new", "x"]) == 1 end)
    assert err =~ "multiple machines"
    assert err =~ "bugs"

    out =
      capture_io(fn ->
        assert Docket.CLI.main(["new", "x", "-m", "bugs", "-s", "hotfix"]) == 0
      end)

    assert out =~ "#1 [bugs/hotfix] x"

    err =
      capture_io(:stderr, fn ->
        assert Docket.CLI.main(["new", "y", "-m", "bugs", "-s", "fixed"]) == 1
      end)

    assert err =~ "not an entry point"
  end

  test "move validates against the item's machine", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)
    capture_io(fn -> Docket.CLI.main(["new", "thing"]) end)

    out = capture_io(fn -> assert Docket.CLI.main(["move", "1", "shaped"]) == 0 end)
    assert out =~ "#1 idea -> shaped"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["move", "1", "shipped"]) == 1 end)
    assert err =~ "illegal transition"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["move", "99", "doing"]) == 1 end)
    assert err =~ "no item"
  end

  test "list hides terminal-state items unless --all and prints no headers for one machine", %{
    dir: dir
  } do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "one"])
      Docket.CLI.main(["new", "two"])
      Docket.CLI.main(["move", "2", "dropped"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["list"]) == 0 end)
    assert out =~ "one"
    refute out =~ "two"
    refute out =~ "sdlc\n"

    all = capture_io(fn -> assert Docket.CLI.main(["list", "--all"]) == 0 end)
    assert all =~ "two"
  end

  test "list groups by machine with headers when several machines have items", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "bugs", """
    stateDiagram-v2
      [*] --> triage
      triage --> fixed
      fixed --> [*]
    """)

    DocketTest.Env.write_machine(
      dir,
      "work",
      "stateDiagram-v2\n  [*] --> idea\n  idea --> done\n  done --> [*]\n"
    )

    capture_io(fn ->
      Docket.CLI.main(["new", "fix crash", "-m", "bugs"])
      Docket.CLI.main(["new", "write spec", "-m", "work"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["list"]) == 0 end)
    assert out =~ ~r/bugs\n.*fix crash.*\n\nwork\n.*write spec/s

    filtered = capture_io(fn -> assert Docket.CLI.main(["list", "-m", "bugs"]) == 0 end)
    assert filtered =~ "fix crash"
    refute filtered =~ "write spec"
    refute filtered =~ "bugs\n"
  end

  test "block, unblock, and show", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)
    capture_io(fn -> Docket.CLI.main(["new", "thing"]) end)

    out =
      capture_io(fn -> assert Docket.CLI.main(["block", "1", "waiting", "on", "api"]) == 0 end)

    assert out =~ "#1 blocked: waiting on api"

    shown = capture_io(fn -> assert Docket.CLI.main(["show", "1"]) == 0 end)
    assert shown =~ "#1 thing"
    assert shown =~ "sdlc"
    assert shown =~ "BLOCKED"
    assert shown =~ "idea"

    capture_io(fn -> assert Docket.CLI.main(["unblock", "1"]) == 0 end)

    shown = capture_io(fn -> assert Docket.CLI.main(["show", "1"]) == 0 end)
    refute shown =~ "BLOCKED"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["show", "9"]) == 1 end)
    assert err =~ "no item"
  end

  test "new --ref creates and links in one step, rejecting bad keys up front", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    out = capture_io(fn -> assert Docket.CLI.main(["new", "thing", "--ref", "ins-9"]) == 0 end)
    assert out =~ "#1 INS-9 [sdlc/idea] thing"

    assert [%{type: :created, title: "thing"}, %{type: :linked, ref: "INS-9"}] =
             Docket.Store.events()

    err =
      capture_io(:stderr, fn -> assert Docket.CLI.main(["new", "x", "--ref", "bogus"]) == 1 end)

    assert err =~ "not a ticket key"
    assert length(Docket.Store.events()) == 2
  end

  test "link attaches a ticket key, uppercased and validated", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)
    capture_io(fn -> Docket.CLI.main(["new", "thing"]) end)

    out = capture_io(fn -> assert Docket.CLI.main(["link", "1", "ins-451"]) == 0 end)
    assert out =~ "#1 linked INS-451  (thing)"
    assert %{1 => %{ref: "INS-451"}} = Docket.Items.all()

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["link", "1", "not_a_key"]) == 1 end)
    assert err =~ "not a ticket key"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["link", "9", "INS-1"]) == 1 end)
    assert err =~ "no item"
  end

  test "ticket keys work anywhere an id goes", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "thing"])
      Docket.CLI.main(["link", "1", "INS-1"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["move", "ins-1", "shaped"]) == 0 end)
    assert out =~ "#1 idea -> shaped"

    shown = capture_io(fn -> assert Docket.CLI.main(["show", "INS-1"]) == 0 end)
    assert shown =~ "#1"
    assert shown =~ "thing"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["show", "INS-99"]) == 1 end)
    assert err =~ "no item"
    assert err =~ "INS-99"
  end

  test "a key shared across items resolves to the sole active one, else errors", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "first pass", "--ref", "INS-1"])
      Docket.CLI.main(["move", "1", "dropped"])
      Docket.CLI.main(["new", "rework", "--ref", "INS-1"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["move", "INS-1", "shaped"]) == 0 end)
    assert out =~ "#2 idea -> shaped"

    capture_io(fn -> Docket.CLI.main(["new", "more rework", "--ref", "INS-1"]) end)

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["show", "INS-1"]) == 1 end)
    assert err =~ "INS-1"
    assert err =~ "#2"
    assert err =~ "#3"
  end

  test "a key whose matches are all terminal errors listing every candidate", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "first pass", "--ref", "INS-1"])
      Docket.CLI.main(["move", "1", "dropped"])
      Docket.CLI.main(["new", "second pass", "--ref", "INS-1"])
      Docket.CLI.main(["move", "2", "dropped"])
    end)

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["show", "INS-1"]) == 1 end)
    assert err =~ "INS-1 matches several items: #1, #2"
  end

  test "list shows a key column after the id and show puts the key in the header", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "linked thing", "--ref", "INS-1"])
      Docket.CLI.main(["new", "wide key", "--ref", "POPS-1234"])
      Docket.CLI.main(["new", "unlinked thing"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["list"]) == 0 end)
    assert out =~ ~r/#1  INS-1      idea/
    assert out =~ ~r/#2  POPS-1234  idea/
    assert out =~ ~r/#3             idea/

    shown = capture_io(fn -> assert Docket.CLI.main(["show", "1"]) == 0 end)
    assert shown =~ "#1 INS-1 linked thing  (sdlc: idea)"
  end

  test "list omits the key column when nothing is linked", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)
    capture_io(fn -> Docket.CLI.main(["new", "plain thing"]) end)

    out = capture_io(fn -> assert Docket.CLI.main(["list"]) == 0 end)
    assert out =~ ~r/#1  idea/
  end

  test "graph prints a machine verbatim and lists the registry when bare", %{dir: dir} do
    mmd = "stateDiagram-v2\n  [*] --> triage\n  triage --> fixed\n  fixed --> [*]\n"
    DocketTest.Env.write_machine(dir, "bugs", mmd)
    capture_io(fn -> Docket.CLI.main(["new", "crash", "-m", "bugs"]) end)

    out = capture_io(fn -> assert Docket.CLI.main(["graph", "bugs"]) == 0 end)
    assert out == mmd

    registry = capture_io(fn -> assert Docket.CLI.main(["graph"]) == 0 end)
    assert registry =~ "bugs"
    assert registry =~ "2 states"
    assert registry =~ "1 item"
    assert registry =~ "bugs.mmd"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["graph", "nope"]) == 1 end)
    assert err =~ "no machine"
  end

  test "stats reports time in state, and cycle time when the machine declares one", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    events = [
      ~s({"ts":"2026-07-01T00:00:00Z","id":1,"type":"created","title":"a","machine":"sdlc","state":"idea"}),
      ~s({"ts":"2026-07-02T00:00:00Z","id":1,"type":"moved","state":"doing"}),
      ~s({"ts":"2026-07-05T00:00:00Z","id":1,"type":"moved","state":"review"}),
      ~s({"ts":"2026-07-06T00:00:00Z","id":1,"type":"moved","state":"shipped"})
    ]

    File.write!(Path.join(dir, "events.jsonl"), Enum.join(events, "\n") <> "\n")

    out = capture_io(fn -> assert Docket.CLI.main(["stats"]) == 0 end)
    assert out =~ ~r/idea\s+1\.0d/
    assert out =~ ~r/doing\s+3\.0d/
    assert out =~ ~r/review\s+1\.0d/
    assert out =~ "cycle time (doing -> shipped)"
    assert out =~ "4.0d"
  end

  test "loading a machine surfaces its warnings on stderr without failing", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "warny", """
    stateDiagram-v2
      [*] --> a
      a --> b
      orphan --> b
      b --> [*]
    """)

    err =
      capture_io(:stderr, fn ->
        capture_io(fn -> assert Docket.CLI.main(["graph", "warny"]) == 0 end)
      end)

    assert err =~ "warning"
    assert err =~ "orphan"
  end

  test "non-numeric ids fail politely" do
    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["move", "abc", "doing"]) == 1 end)
    assert err =~ "error:"
    assert err =~ "abc"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["show", "1x"]) == 1 end)
    assert err =~ "error:"
  end

  test "invalid options and stray arguments fail politely" do
    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["list", "--bogus"]) == 1 end)
    assert err =~ "error:"
    assert err =~ "--bogus"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["list", "stray"]) == 1 end)
    assert err =~ "error:"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["new", "x", "--bogus"]) == 1 end)
    assert err =~ "error:"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["new", "x", "-s"]) == 1 end)
    assert err =~ "error:"
  end

  test "new without a title fails politely", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["new", "-m", "sdlc"]) == 1 end)
    assert err =~ "title"
    assert Docket.Store.events() == []
  end

  test "hand-edited log defects fail politely with the offending line number", %{dir: dir} do
    log = Path.join(dir, "events.jsonl")

    good =
      ~s({"ts":"2026-07-01T00:00:00Z","id":1,"type":"created","title":"a","machine":"sdlc","state":"idea"})

    ts = "2026-07-01T00:00:00Z"

    for bad <- [
          "not json",
          "[1, 2]",
          ~s({"ts":"#{ts}","id":2,"type":"created","title":"b","machine":"sdlc","state":"idea","resaon":"typo"}),
          ~s({"ts":"#{ts}","id":2,"type":"zapped"}),
          ~s({"ts":"#{ts}","id":"two","type":"moved","state":"doing"}),
          ~s({"ts":"#{ts}","id":2,"type":"blocked"}),
          ~s({"ts":"#{ts}","id":2,"type":"linked"}),
          ~s({"ts":"#{ts}","id":2,"type":"moved"}),
          ~s({"ts":"#{ts}","id":2,"type":"created","title":null,"machine":"sdlc","state":"idea"}),
          ~s({"id":2,"type":"unblocked"}),
          ~s({"ts":"garbage","id":2,"type":"moved","state":"doing"})
        ] do
      File.write!(log, good <> "\n" <> bad <> "\n")
      err = capture_io(:stderr, fn -> assert Docket.CLI.main(["list"]) == 1 end)
      assert err =~ "error:"
      assert err =~ "events.jsonl line 2"
    end
  end

  test "stats includes the ongoing stay for items still in a non-terminal state", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    two_days_ago =
      DateTime.utc_now()
      |> DateTime.add(-2 * 86_400)
      |> DateTime.truncate(:second)
      |> DateTime.to_iso8601()

    File.write!(
      Path.join(dir, "events.jsonl"),
      ~s({"ts":"#{two_days_ago}","id":1,"type":"created","title":"a","machine":"sdlc","state":"idea"}\n)
    )

    out = capture_io(fn -> assert Docket.CLI.main(["stats"]) == 0 end)
    assert out =~ ~r/idea\s+2\.0d/
  end

  test "commands fail politely when an item's machine file was deleted", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "bugs", """
    stateDiagram-v2
      [*] --> triage
      triage --> fixed
      fixed --> [*]
    """)

    DocketTest.Env.write_machine(dir, "work", "stateDiagram-v2\n  [*] --> idea\n  idea --> [*]\n")
    capture_io(fn -> Docket.CLI.main(["new", "crash", "-m", "bugs"]) end)
    File.rm!(Path.join([dir, "machines", "bugs.mmd"]))

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["move", "1", "fixed"]) == 1 end)
    assert err =~ "no machine"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["list"]) == 1 end)
    assert err =~ "no machine"
  end

  test "an unreadable machine file fails politely and shows as INVALID in the registry", %{
    dir: dir
  } do
    File.mkdir_p!(Path.join([dir, "machines", "bogus.mmd"]))

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["graph", "bogus"]) == 1 end)
    assert err =~ "cannot read"

    registry = capture_io(fn -> assert Docket.CLI.main(["graph"]) == 0 end)
    assert registry =~ "bogus  INVALID:"
  end

  test "an unreadable event log fails politely", %{dir: dir} do
    File.mkdir_p!(Path.join(dir, "events.jsonl"))

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["list"]) == 1 end)
    assert err =~ "error:"
    assert err =~ "cannot read"
  end

  test "map renders states in declaration order with items under their states", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "first thing"])
      Docket.CLI.main(["new", "second thing"])
      Docket.CLI.main(["move", "2", "shaped"])
      Docket.CLI.main(["move", "2", "doing"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)

    assert out =~ ~r/^idea\b[^\n]*\n  #1\s+0d  first thing$/m
    assert out =~ ~r/^doing\n  #2\s+0d  second thing$/m
    assert out =~ ~r/idea.*shaped.*doing.*review.*shipped.*dropped/s
  end

  test "map draws spine connectors only between neighbors with a transition", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "thing"])
      Docket.CLI.main(["move", "1", "shaped"])
      Docket.CLI.main(["move", "1", "doing"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)

    assert out =~ "  0d  thing\n│\nreview"
    assert out =~ "review\n│\nshipped"
    assert out =~ ~r/^shipped\n\ndropped/m
  end

  test "map annotates transitions that skip past the vertical neighbor", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "loopy", """
    stateDiagram-v2
      [*] --> todo
      todo --> doing
      doing --> review
      review --> doing
      review --> done
      todo --> dropped
      done --> [*]
      dropped --> [*]
    """)

    capture_io(fn -> Docket.CLI.main(["new", "thing", "-m", "loopy"]) end)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)

    assert out =~ ~r/^todo ──▶ dropped$/m
    assert out =~ ~r/^review ──▶ doing$/m
    assert out =~ ~r/^doing$/m
  end

  test "map summarizes terminal-state items as a count unless --all", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "keeper"])
      Docket.CLI.main(["new", "goner"])
      Docket.CLI.main(["move", "2", "dropped"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)
    assert out =~ ~r/^dropped  \(1 item\)$/m
    assert out =~ ~r/^shipped$/m
    refute out =~ "goner"

    all = capture_io(fn -> assert Docket.CLI.main(["map", "--all"]) == 0 end)
    assert all =~ ~r/^dropped\n  #2\s+0d  goner$/m
  end

  test "map groups by machine with headers, skipping machines without items", %{dir: dir} do
    DocketTest.Env.write_machine(dir, "bugs", """
    stateDiagram-v2
      [*] --> triage
      triage --> fixed
      fixed --> [*]
    """)

    DocketTest.Env.write_machine(
      dir,
      "work",
      "stateDiagram-v2\n  [*] --> idea\n  idea --> done\n  done --> [*]\n"
    )

    DocketTest.Env.write_machine(
      dir,
      "empty",
      "stateDiagram-v2\n  [*] --> open\n  open --> closed\n  closed --> [*]\n"
    )

    capture_io(fn ->
      Docket.CLI.main(["new", "fix crash", "-m", "bugs"])
      Docket.CLI.main(["new", "write spec", "-m", "work"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)
    assert out =~ ~r/^bugs\ntriage\n.*fix crash.*\n\nwork\nidea\n.*write spec/s
    refute out =~ "open"
  end

  test "map with a name renders that machine even when it has no items", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    DocketTest.Env.write_machine(
      dir,
      "empty",
      "stateDiagram-v2\n  [*] --> open\n  open --> closed\n  closed --> [*]\n"
    )

    capture_io(fn -> assert Docket.CLI.main(["new", "thing", "-m", "sdlc"]) == 0 end)

    out = capture_io(fn -> assert Docket.CLI.main(["map", "empty"]) == 0 end)
    assert out =~ "open\n│\nclosed"
    refute out =~ "thing"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["map", "nope"]) == 1 end)
    assert err =~ "no machine"
  end

  test "map shows a padded ref column and blocked flags on item lines", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "linked thing", "--ref", "INS-1"])
      Docket.CLI.main(["new", "plain thing"])
      Docket.CLI.main(["block", "2", "waiting on api"])
    end)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)

    assert out =~ ~r/^  #1  INS-1    0d  linked thing$/m
    assert out =~ ~r/^  #2           0d  plain thing  \[BLOCKED: waiting on api\]$/m
  end

  test "map keeps items visible when their state was removed from the machine", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    capture_io(fn ->
      Docket.CLI.main(["new", "orphaned thing"])
      Docket.CLI.main(["move", "1", "shaped"])
    end)

    DocketTest.Env.write_machine(dir, "sdlc", """
    stateDiagram-v2
      [*] --> idea
      idea --> doing
      doing --> shipped
      shipped --> [*]
    """)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)

    assert out =~ ~r/^shaped \(not in machine\)\n  #1\s+0d  orphaned thing$/m
    assert out =~ ~r/shipped.*shaped \(not in machine\)/s
  end

  test "map with no items prints nothing here", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    out = capture_io(fn -> assert Docket.CLI.main(["map"]) == 0 end)
    assert out == "nothing here\n"
  end

  test "map rejects bad options and stray arguments", %{dir: dir} do
    DocketTest.Env.write_sdlc(dir)

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["map", "--bogus"]) == 1 end)
    assert err =~ "error:"
    assert err =~ "--bogus"

    err = capture_io(:stderr, fn -> assert Docket.CLI.main(["map", "a", "b"]) == 1 end)
    assert err =~ "unexpected argument"
  end

  test "unknown commands print usage to stderr and fail" do
    out = capture_io(:stderr, fn -> assert Docket.CLI.main(["bogus"]) == 1 end)
    assert out =~ "docket"
    assert out =~ "new <title>"
    assert out =~ "--ref"
    assert out =~ "link <id> <ref>"
    assert out =~ "map [machine]"
  end
end
