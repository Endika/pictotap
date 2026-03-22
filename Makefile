.PHONY: help format format-check analyze pubget run-web build-web clean test

help:
	@echo "Available targets:"
	@echo "  make format        - Run official Dart formatter"
	@echo "  make format-check  - Check formatting (CI)"
	@echo "  make analyze       - Run flutter analyze"
	@echo "  make test          - Run flutter test"
	@echo "  make pubget        - Run flutter pub get"
	@echo "  make run-web       - Run flutter run"
	@echo "  make build-web     - Build web with offline-first PWA"
	@echo "  make clean         - Run flutter clean"

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

build-web:
	flutter build web --release --pwa-strategy=offline-first

clean:
	flutter clean

