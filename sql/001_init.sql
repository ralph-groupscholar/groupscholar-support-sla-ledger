CREATE SCHEMA IF NOT EXISTS groupscholar_support_sla_ledger;

CREATE TABLE IF NOT EXISTS groupscholar_support_sla_ledger.sla_events (
  id BIGSERIAL PRIMARY KEY,
  ticket_id TEXT NOT NULL,
  channel TEXT NOT NULL,
  priority TEXT NOT NULL,
  opened_at TIMESTAMPTZ NOT NULL,
  first_response_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  responder TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS sla_events_opened_at_idx
  ON groupscholar_support_sla_ledger.sla_events (opened_at DESC);

CREATE INDEX IF NOT EXISTS sla_events_priority_idx
  ON groupscholar_support_sla_ledger.sla_events (priority);
