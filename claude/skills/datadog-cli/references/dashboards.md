# Dashboards Reference

## Commands

| Command | Description |
|---------|-------------|
| `dashboards list` | List all dashboards |
| `dashboards get` | Get full dashboard definition |
| `dashboard-lists list` | List all dashboard lists |
| `dashboard-lists get` | Get dashboard list details |
| `dashboard-lists items` | List dashboards in a list |

## Flags

| Flag | Commands | Description |
|------|----------|-------------|
| `--id` | get | Dashboard ID |

## Examples

### List & Get
```bash
npx @leoflores/datadog-cli dashboards list --pretty
npx @leoflores/datadog-cli dashboards get --id "abc-def-ghi" --pretty
```

### Dashboard Lists
```bash
npx @leoflores/datadog-cli dashboard-lists list --pretty
npx @leoflores/datadog-cli dashboard-lists get --id 123 --pretty
npx @leoflores/datadog-cli dashboard-lists items --id 123 --pretty
```

## Template Variables

```json
{"name": "env", "prefix": "env", "default": "prod"}
```

Use in queries: `avg:system.cpu.user{$env,$service}`

## Widget Types

### Timeseries
```json
{"definition": {"type": "timeseries", "title": "CPU", "requests": [{"q": "avg:system.cpu.user{*}"}]}}
```

### Query Value
```json
{"definition": {"type": "query_value", "title": "Errors", "requests": [{"q": "sum:errors{*}.as_count()"}]}}
```

### Top List
```json
{"definition": {"type": "toplist", "title": "Top Services", "requests": [{"q": "top(sum:errors{*} by {service}, 10, 'sum', 'desc')"}]}}
```

## Layout Types

- **ordered**: Auto-arranged responsive grid
- **free**: Manual positioning with x, y, width, height
