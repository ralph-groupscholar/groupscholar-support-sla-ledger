#!/usr/bin/env guile
!#

(use-modules (ice-9 match)
             (ice-9 getopt-long)
             (ice-9 popen)
             (ice-9 rdelim)
             (srfi srfi-1)
             (srfi srfi-19))

(define (now-iso)
  (date->string (current-date) "~Y-~m-~dT~H:~M:~SZ"))

(define (sql-escape value)
  (let ((chars (string->list value)))
    (list->string
     (append-map (lambda (ch)
                   (if (char=? ch #\')
                       (list #\' #\')
                       (list ch)))
                 chars))))

(define (sql-value value)
  (if (or (not value) (string=? value ""))
      "NULL"
      (string-append "'" (sql-escape value) "'")))

(define (env-required name)
  (let ((val (getenv name)))
    (if (or (not val) (string=? val ""))
        (begin
          (format (current-error-port) "Missing required env var: ~a~%" name)
          (exit 1))
        val)))

(define (run-psql sql)
  (let* ((db-url (env-required "DATABASE_URL"))
         (port (open-pipe* OPEN_READ "psql" db-url "-t" "-A" "-F" "|" "-c" sql))
         (output (read-string port)))
    (close-pipe port)
    output))

(define (exec-psql sql)
  (let ((db-url (env-required "DATABASE_URL")))
    (let ((status (system* "psql" db-url "-c" sql)))
      (if (not (zero? status))
          (begin
            (format (current-error-port) "psql failed with status ~a~%" status)
            (exit 1))))))

(define (build-insert fields)
  (let* ((ticket-id (assoc-ref fields 'ticket))
         (channel (assoc-ref fields 'channel))
         (priority (assoc-ref fields 'priority))
         (opened-at (assoc-ref fields 'opened))
         (first-response (assoc-ref fields 'first-response))
         (resolved (assoc-ref fields 'resolved))
         (responder (assoc-ref fields 'responder))
         (notes (assoc-ref fields 'notes)))
    (string-append
     "INSERT INTO groupscholar_support_sla_ledger.sla_events "
     "(ticket_id, channel, priority, opened_at, first_response_at, resolved_at, responder, notes) VALUES ("
     (sql-value ticket-id) ", "
     (sql-value channel) ", "
     (sql-value priority) ", "
     (sql-value opened-at) ", "
     (sql-value first-response) ", "
     (sql-value resolved) ", "
     (sql-value responder) ", "
     (sql-value notes) ");")))

(define (usage)
  (display "groupscholar-support-sla-ledger\n\n")
  (display "Usage:\n")
  (display "  sla-ledger add --ticket ID --channel email --priority high --opened 2026-02-01T10:00:00Z [--first-response ...] [--resolved ...] [--responder ...] [--notes ...]\n")
  (display "  sla-ledger list [--limit 20]\n")
  (display "  sla-ledger summary [--since 2026-01-01]\n")
  (display "  sla-ledger help\n\n"))

(define (handle-add args)
  (let* ((spec '((ticket (value #t))
                 (channel (value #t))
                 (priority (value #t))
                 (opened (value #t))
                 (first-response (value #t))
                 (resolved (value #t))
                 (responder (value #t))
                 (notes (value #t))))
         (options (getopt-long args spec))
         (ticket (assoc-ref options 'ticket))
         (channel (assoc-ref options 'channel))
         (priority (or (assoc-ref options 'priority) "normal"))
         (opened (assoc-ref options 'opened)))
    (when (or (not ticket) (not channel) (not opened))
      (format (current-error-port) "Missing required fields. Need --ticket, --channel, --opened.\n")
      (usage)
      (exit 1))
    (let* ((fields `((ticket . ,ticket)
                     (channel . ,channel)
                     (priority . ,priority)
                     (opened . ,opened)
                     (first-response . ,(assoc-ref options 'first-response))
                     (resolved . ,(assoc-ref options 'resolved))
                     (responder . ,(assoc-ref options 'responder))
                     (notes . ,(assoc-ref options 'notes))))
           (sql (build-insert fields)))
      (exec-psql sql)
      (format #t "Recorded ticket ~a at ~a\n" ticket (now-iso)))))

(define (handle-list args)
  (let* ((spec '((limit (value #t))))
         (options (getopt-long args spec))
         (limit (or (assoc-ref options 'limit) "20"))
         (sql (string-append
               "SELECT ticket_id || '|' || priority || '|' || channel || '|' || opened_at || '|' || "
               "COALESCE(first_response_at::text,'') || '|' || COALESCE(resolved_at::text,'') || '|' || "
               "COALESCE(responder,'') "
               "FROM groupscholar_support_sla_ledger.sla_events "
               "ORDER BY opened_at DESC "
               "LIMIT " limit ";"))
         (rows (run-psql sql)))
    (display "ticket_id|priority|channel|opened_at|first_response_at|resolved_at|responder\n")
    (display rows)))

(define (handle-summary args)
  (let* ((spec '((since (value #t))))
         (options (getopt-long args spec))
         (since (or (assoc-ref options 'since) "1970-01-01"))
         (sql (string-append
               "SELECT priority || '|' || count(*) || '|' || "
               "COALESCE(round(avg(extract(epoch from (first_response_at - opened_at))/3600)::numeric,2)::text,'') || '|' || "
               "COALESCE(round(avg(extract(epoch from (resolved_at - opened_at))/3600)::numeric,2)::text,'') "
               "FROM groupscholar_support_sla_ledger.sla_events "
               "WHERE opened_at >= '" (sql-escape since) "' "
               "GROUP BY priority "
               "ORDER BY priority;"))
         (rows (run-psql sql)))
    (display "priority|count|avg_first_response_hours|avg_resolution_hours\n")
    (display rows)))

(define (main argv)
  (let ((args (cdr argv)))
    (match args
      ((or () ("help")) (usage))
      (("add" . rest) (handle-add rest))
      (("list" . rest) (handle-list rest))
      (("summary" . rest) (handle-summary rest))
      (_ (begin
           (format (current-error-port) "Unknown command.\n")
           (usage)
           (exit 1))))))

(when (not (getenv "SLA_LEDGER_TEST"))
  (main (command-line)))
