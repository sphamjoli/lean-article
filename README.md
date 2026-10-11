# Lean on me? Maybe NOT! — executable examples

A school collection request must have approval from a parent or guardian authorised for that particular child. These examples separate checking collection details, checking recorded permission, and justifying that recorded permission reflects actual authority.

## Rust workspace

| Crate | Acceptance rule |
|---|---|
| `collection-details` | Intentionally incomplete: matching details and signed-in-account membership |
| `child-authorisation` | Fixed: shared details rule plus permission for this particular child |
| `collection-types` | Shared domain inputs used by both implementations |


`collection-types` supplies distinct account, child, collector and day identifiers. `collection-details` checks that the approving account appears in the supplied signed-in-parent list, the child and collector match the request, and both request and approval refer to today. `child-authorisation` reuses those checks and also requires an account–child entry in the school records.

Eve is an authenticated parent of another child. Her approval for Charlie passes the details rule, but the authorisation rule rejects it with accurate records. If Eve is wrongly recorded as authorised for Charlie, the authorisation rule accepts it too. This demonstrates different failures without impersonation, mismatched details or a forged proof.

Run `cargo run --locked -p child-authorisation --example school_collection` to see the two decisions, then `cargo test --workspace --locked`. Run formatting and lint checks with `cargo fmt --all -- --check` and `cargo clippy --workspace --all-targets --locked -- -D warnings`.

## Lean models

From `lean/`, run `lake build` and `lake env lean AxiomAudit.lean`. The toolchain pins Lean 4.19.0 and uses only its standard library.

`Collection/Rules.lean` defines executable Boolean models for both Rust rules and proves their acceptance characterisations. The repaired rule meets the actual-authority requirement only under `RecordsFaithful`: each recorded permission implies actual permission. Missing entries can deny legitimate requests; the safety theorem requires no false permissions, rather than complete records.

`Collection/Examples.lean` proves Eve passes the details rule, violates the requirement, and is rejected by the repaired rule with accurate records. A positive Alice example instantiates the conditional theorem for a legitimate approval. It also proves that bad records allow Eve and cannot satisfy the faithfulness premise. The conditional theorem remains valid; its premise cannot be supplied for that state.

## Evidence boundary

The Lean definitions are manually written models of the Rust functions. Both use list membership, equality and conjunction. The Rust named `RecordedAuthorisation` maps to an account–child pair in Lean. Rust's `u64` identifiers map to Lean naturals within the `u64` range; neither implementation performs ID arithmetic. The models check both date equalities, including the requested date.

Rust regression tests and manual source review provide limited evidence of correspondence, but there is no verified Rust-to-Lean translation, compiler theorem or theorem about the deployed executable. The Lean results establish properties of the Lean models. Authentication, approval provenance, the real date, permission-record maintenance and release of a child remain outside these examples. A caller must authenticate the supplied approval; matching an account ID is not authentication. Actual authority is a separately supplied relation, not a fact established by the checker.

These examples use no cryptographic proof protocol. They illustrate valid formal proofs of supplied statements and the additional obligations needed to apply those statements to running software.

Run `bash scripts/check.sh` for the combined Rust and Lean checks. Rust 1.97.1 is pinned; the declared minimum is 1.97, and only 1.97.1 has been tested. Python 3 and Bash are required by the combined checker. There are no external Rust crates.

The numeric examples use Alice account 1, Eve account 2, Charlie child 10 and another child 20. Day 42 is an opaque example value, not a calendar conversion. The signed-in and permission lists are unbounded supplied inputs; evaluation scans them linearly, allocates no memory and provides no production resource limit.

The axiom audit allows only the standard Lean foundations `propext`, `Classical.choice` and `Quot.sound`; the current proofs use only the first and third. No added axioms or proof placeholders are used.

## Developer commands

`make hooks-install` installs the pinned Lefthook dependency and Git hooks with Bun. This requires an initialised Git repository. Pre-commit checks source comments and Markdown paragraphs, configuration syntax, affected Rust formatting and lint, and affected Lean proofs. Commit messages use Conventional Commits with optional `rust`, `lean`, `docs`, `ci`, `deps` or `tooling` scopes. Pre-push runs `make check`. Hooks fail when required tools are missing and do not rewrite or stage files.

`make check` runs style, configuration, Rust and Lean checks; `make demo` runs the collection example. Ruby validates YAML and Python 3.11 or later validates TOML. The comment scanner uses line-based checks, not a full Rust parser. Staged style and TOML checks inspect index contents; YAML, shell and language builds inspect the working tree. Commit only after reviewing the staged changes.

`make docker-build` builds the verification image with pinned Rust and Lean versions. `make docker-check` runs the checks without container network access; `make docker-demo` runs the example. The image copies only project inputs and builds its own artefacts. Image construction requires network access for the base image, operating-system packages and Lean toolchain. `make audit` separately fetches RustSec advisories on the host.
