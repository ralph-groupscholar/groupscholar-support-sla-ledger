SHELL := /bin/bash

.PHONY: test format

test:
	SLA_LEDGER_TEST=1 guile tests/sla-ledger.test.scm
