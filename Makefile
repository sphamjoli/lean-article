SHELL := /bin/bash

IMAGE ?= lean-article-checks

.PHONY: help hooks-install check style config rust-lint rust-test rust-doc lean-check demo audit docker-build docker-check docker-demo
help:
	@echo "hooks-install check demo audit docker-build docker-check docker-demo"
hooks-install:
	bun install --frozen-lockfile
check: style config
	bash scripts/check.sh
style:
	python3 scripts/check-style.py
config:
	python3 scripts/check-config.py
	ruby scripts/check-yaml.rb
	bash scripts/check-shell.sh
rust-lint:
	cargo fmt --all -- --check
	cargo clippy --workspace --all-targets --all-features --locked -- -D warnings
rust-test:
	cargo test --workspace --all-features --locked
rust-doc:
	RUSTDOCFLAGS="-D warnings" cargo doc --workspace --all-features --no-deps --locked
lean-check:
	bash scripts/check-lean.sh
demo:
	cargo run --locked -p child-authorisation --example school_collection
audit:
	cargo audit
docker-build:
	docker build -t $(IMAGE) .
docker-check:
	docker run --rm --network none $(IMAGE)
docker-demo:
	docker run --rm --network none $(IMAGE) make demo
