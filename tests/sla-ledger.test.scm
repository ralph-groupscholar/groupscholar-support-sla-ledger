(use-modules (srfi srfi-64))

(setenv "SLA_LEDGER_TEST" "1")
(load (string-append (or (getenv "PWD") ".") "/bin/sla-ledger.scm"))

(test-begin "sla-ledger")

(test-equal "sql-escape doubles quotes"
  "O''Reilly"
  (sql-escape "O'Reilly"))

(test-equal "sql-value NULL for empty"
  "NULL"
  (sql-value ""))

(test-equal "sql-value wraps"
  "'GS-2001'"
  (sql-value "GS-2001"))

(test-assert "build-insert has schema"
  (let ((sql (build-insert '((ticket . "GS-9")
                             (channel . "email")
                             (priority . "high")
                             (opened . "2026-02-01T00:00:00Z")
                             (first-response . #f)
                             (resolved . #f)
                             (responder . "Mentor")
                             (notes . "Follow-up")))))
    (and (string-contains sql "groupscholar_support_sla_ledger.sla_events")
         (string-contains sql "INSERT INTO"))))

(test-end "sla-ledger")
