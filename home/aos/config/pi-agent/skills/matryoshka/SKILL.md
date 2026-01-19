---
name: matryoshka
description: Analyze large documents (100x larger than LLM context) using recursive language model with Nucleus DSL. Use when searching, filtering, aggregating text logs, reports, or structured text data without loading everything into context.
---

# Matryoshka - Recursive Language Model

Analyze large documents (> 300 lines). Use when searching, filtering, aggregating text logs, reports, or structured text data without loading everything into context.

## Workflow

1. **Start server** - Launch `lattice-http` in background (auto-starts if needed)
2. **Load document** - Load your file for analysis
3. **Query progressively** - Refine with grep → filter → aggregate
4. **Close session** - Free memory when done

Query results return compact handle stubs like `$res1: Array(1000) [preview...]` instead of full data. Use `expand` to inspect only what you need.

## Quick Start

```bash
# Start server
scripts/start-server.sh

# Load a document
scripts/load.sh ./logs.txt

# Search for patterns
scripts/query.sh '(grep "ERROR")'

# Count results
scripts/query.sh '(count RESULTS)'

# Sum numeric values
scripts/query.sh '(sum RESULTS)'

# Close session
scripts/close.sh
```

## Nucleus Query Examples

### Search Commands

```scheme
(grep "pattern")              ; Regex search
(fuzzy_search "query" 10)     ; Fuzzy search, top N results
(text_stats)                  ; Document metadata
(lines 1 100)                 ; Get line range
```

### Collection Operations

```scheme
(filter RESULTS (lambda x (match x "pattern" 0)))  ; Filter by regex
(map RESULTS (lambda x (match x "(\\d+)" 1)))      ; Extract from each
(sum RESULTS)                                       ; Sum numbers in results
(count RESULTS)                                     ; Count items
```

### String Operations

```scheme
(match str "pattern" 0)       ; Regex match, return group N
(replace str "from" "to")     ; String replacement
(split str "," 0)             ; Split and get index
(parseInt str)                ; Parse integer
(parseFloat str)              ; Parse float
```

### Type Coercion

```scheme
(parseDate "Jan 15, 2024")           ; -> "2024-01-15"
(parseCurrency "$1,234.56")          ; -> 1234.56
(parseNumber "1,234,567")            ; -> 1234567
(coerce value "date")                ; Coerce to date
(extract str "\\$[\\d,]+" 0 "currency")  ; Extract and parse
```

## Variables

- `RESULTS` - Latest array result (auto-bound by grep, filter, etc.)
- `_0`, `_1`, `_2`, ... - Results from each command in sequence
- `context` - Raw document content

## Common Patterns

### Find and count error entries
```scheme
(grep "ERROR")
(count RESULTS)
```

### Extract and sum sales from specific region
```scheme
(grep "SALES.*NORTH")
(map RESULTS (lambda x (parseCurrency (match x "\\$[\\d,]+" 0))))
(sum RESULTS)
```

### Find recent entries by date
```scheme
(grep "2024-01-1")
(filter RESULTS (lambda x (> (parseDate (match x "\\d{4}-\\d{2}-\\d{2}" 0)) "2024-01-15")))
```

### Extract emails from text
```scheme
(grep "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}")
```

## Script Reference

All scripts read default port from `LATTICE_PORT` env var (default: 3456).

### `start-server.sh`
Starts `lattice-http` server in background.

```bash
scripts/start-server.sh [port]   # Default: 3456
```

### `load.sh`
Loads a document for analysis.

```bash
scripts/load.sh <file-path>
scripts/load.sh ./logs.txt

# Or pass content directly
scripts/load.sh - < file.txt  # Read from stdin
```

### `query.sh`
Executes a Nucleus query.

```bash
scripts/query.sh '(grep "ERROR")'
scripts/query.sh '(count RESULTS)'
```

### `status.sh`
Shows session status (timeout, queries, document info).

```bash
scripts/status.sh
```

### `bindings.sh`
Shows current variable bindings.

```bash
scripts/bindings.sh
```

### `expand.sh`
Expands a handle to see full data (optional limit/offset).

```bash
scripts/expand.sh RESULTS           # Show full RESULTS
scripts/expand.sh RESULTS 10        # First 10 items
scripts/expand.sh RESULTS 10 20     # Offset 10, limit 10
```

### `close.sh`
Closes the current session and frees memory.

```bash
scripts/close.sh
```

### `stats.sh`
Gets document statistics (length, line count).

```bash
scripts/stats.sh
```

### `health.sh`
Health check with session info.

```bash
scripts/health.sh
```

## Troubleshooting

### Server not running
```bash
# Check if server is running
scripts/health.sh

# Restart
scripts/close.sh
scripts/start-server.sh
```

### Session expired
Sessions auto-expire after 10 minutes of inactivity. Simply load the document again:
```bash
scripts/load.sh ./file.txt
```

### Query returns errors
- Check syntax - Nucleus uses S-expressions with parentheses
- Use single quotes around queries to avoid shell expansion
- Reference `scripts/help.sh` for command reference

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LATTICE_PORT` | 3456 | Server port |
| `LATTICE_HOST` | localhost | Server host |
| `LATTICE_TIMEOUT` | 600 | Session timeout (seconds) |
