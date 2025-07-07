INSERT INTO groupscholar_support_sla_ledger.sla_events
(ticket_id, channel, priority, opened_at, first_response_at, resolved_at, responder, notes)
VALUES
('GS-1024', 'email', 'high', '2026-01-07T14:12:00Z', '2026-01-07T16:05:00Z', '2026-01-09T18:30:00Z', 'A. Mentor', 'Scholar reported portal access issue.'),
('GS-1025', 'sms', 'normal', '2026-01-10T15:40:00Z', '2026-01-10T17:10:00Z', '2026-01-11T20:45:00Z', 'J. Rivera', 'Follow-up on document upload.'),
('GS-1031', 'email', 'urgent', '2026-01-15T09:20:00Z', '2026-01-15T09:45:00Z', '2026-01-16T12:15:00Z', 'S. Patel', 'Deadline extension request.'),
('GS-1038', 'web', 'normal', '2026-01-22T19:05:00Z', '2026-01-22T20:40:00Z', '2026-01-24T16:50:00Z', 'M. Lopez', 'Scholar needs clarification on eligibility.'),
('GS-1042', 'email', 'high', '2026-01-28T13:30:00Z', '2026-01-28T15:05:00Z', '2026-01-29T22:10:00Z', 'K. Nguyen', 'Updated recommendation letter missing.')
ON CONFLICT DO NOTHING;
