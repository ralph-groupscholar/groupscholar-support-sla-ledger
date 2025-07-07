# groupscholar-support-sla-ledger

CLI for tracking support response/resolution SLAs and summarizing performance across channels and priorities.

## Features
- Log support tickets with response and resolution timestamps
- List recent tickets with core metadata
- Summarize SLA performance by priority and time window
- Postgres-backed storage with dedicated schema

## Tech
- Scheme (Guile)
- PostgreSQL

## Setup
1. Install Guile.
2. Set `DATABASE_URL` for production access.
3. Run migrations and seed data.

```bash
export DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DB"
./scripts/db_migrate.sh
./scripts/db_seed.sh
```

## Usage
```bash
./scripts/run.sh add --ticket GS-1100 --channel email --priority high \
  --opened 2026-02-01T10:00:00Z --first-response 2026-02-01T12:00:00Z \
  --resolved 2026-02-03T09:00:00Z --responder "A. Mentor" --notes "Portal issue"

./scripts/run.sh list --limit 15

./scripts/run.sh summary --since 2026-01-01
```

## Testing
```bash
make test
```

## Notes
- `DATABASE_URL` must be set in the environment.
- This project uses the schema `groupscholar_support_sla_ledger`.
