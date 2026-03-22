.PHONY: help format format-check analyze pubget run-web build-web clean test setup coverage

help:
	@echo "Available targets:"
	@echo "  make setup         - Install deps and git hooks (lefthook)"
	@echo "  make format        - Run official Dart formatter"
	@echo "  make format-check  - Check formatting (CI)"
	@echo "  make analyze       - Run flutter analyze"
	@echo "  make test          - Run flutter test"
	@echo "  make coverage      - Run tests and show coverage"
	@echo "  make pubget        - Run flutter pub get"
	@echo "  make run-web       - Run flutter run"
	@echo "  make build-web     - Build web with offline-first PWA"
	@echo "  make clean         - Run flutter clean"

setup:
	flutter pub get
	@command -v lefthook >/dev/null 2>&1 && lefthook install || echo "Install lefthook: https://github.com/evilmartians/lefthook#install"

format:
	dart format .

format-check:
	dart format --set-exit-if-changed .

analyze:
	flutter analyze

test:
	flutter test

pubget:
	flutter pub get

run-web:
	flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0

coverage:
	flutter test --coverage
	@awk 'BEGIN{s=0}/^SF:.*lib\/l10n\//{s=1}/^end_of_record/{if(s){s=0;next}}!s' coverage/lcov.info > coverage/lcov_filtered.info
	@awk '/^LF:/{t+=substr($$0,4)}/^LH:/{h+=substr($$0,4)}END{printf "Coverage: %.1f%% (excluding generated l10n)\n",h/t*100}' coverage/lcov_filtered.info

build-web:
	flutter build web --release --pwa-strategy=offline-first

clean:
	flutter clean

