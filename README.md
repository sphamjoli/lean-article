# Lean on me? Maybe NOT!

A school collection request needs approval from a parent or guardian authorised for that particular child. This project provides an incomplete Rust rule, a rule that adds child-specific recorded permission, and Lean models showing what each establishes.

## Choose how to run

| Route | Install on your computer | Use it for |
|---|---|---|
| Docker | Git and Docker | Run the example and all checks in the supplied environment |
| Local Rust demo | Git, Rust through rustup and system build tools | Run the example or Rust tests |
| Local full checks | The Rust tools above, elan, Python 3.11+, Ruby, Make and Bash | Edit the code and check Rust, Lean and configuration |

Bun is needed only for installing Git hooks. Docker supplies its own Rust, Lean, Python, Ruby, Make and Bash. The local shell instructions below target macOS and Ubuntu 24.04 or Debian 12. On Windows, use a WSL2 Linux shell for the local route, or Docker Desktop for the container route.

## Get the project

If `git --version` is unavailable, install Git using the [system-tool instructions](#system-tools) below or the [Git installation guide](https://git-scm.com/downloads). Clone the repository so the check scripts can inspect tracked files:

```sh
git clone https://github.com/sphamjoli/lean-article.git
cd lean-article
```

Run the commands below from this repository directory unless stated otherwise.

## Run with Docker

Install [Docker Desktop or Docker Engine](https://docs.docker.com/get-started/get-docker/) and start it. Confirm the daemon is available:

```sh
docker info
```

Build the image, then run the example and the full checks:

```sh
docker build -t lean-article-checks .
docker run --rm --network none lean-article-checks make demo
docker run --rm --network none lean-article-checks
```

The image build downloads its pinned Rust base image, system packages and Lean toolchain, and runs the checks. It can take several minutes on the first build. The two subsequent commands run without container network access. They do not require host Rust or Lean installations.

If Make is already installed, the equivalent commands are `make docker-build`, `make docker-demo` and `make docker-check`, in that order.

## Install the local tools

For the Rust-only demo, complete **System tools** and **Rust**, then skip to **Run the example**. For the full suite, continue through **Lean** as well.

### System tools

The package commands below install the system tools for the full suite. For the Rust-only demo, Git, curl and the native build tools suffice; Python and Ruby are needed for the other checks.

On macOS, install Xcode Command Line Tools if they are missing:

```sh
xcode-select --install
```

Install [Homebrew](https://brew.sh/) if needed, follow its terminal setup instructions, then install the remaining tools:

```sh
brew install git python ruby
```

Xcode Command Line Tools supplies Make; macOS supplies Bash. On Ubuntu 24.04 or Debian 12, install the system tools with:

```sh
sudo apt-get update
sudo apt-get install git curl build-essential make bash python3 ruby unzip
```

Verify the tools before proceeding. Python must be 3.11 or later because the configuration checker uses `tomllib`:

```sh
git --version
make --version
bash --version
python3 --version
ruby --version
```

### Rust

Install [rustup using the official Rust installer](https://rust-lang.org/tools/install/), then activate its commands in your current shell:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
rustup toolchain install 1.97.1 --profile minimal --component rustfmt,clippy
rustc --version
cargo --version
```

The repository pins Rust 1.97.1 with rustfmt and Clippy. Its declared minimum is 1.97, but only 1.97.1 has been tested. There are no external Rust crate dependencies.

### Lean

Install [elan, Lean's toolchain manager](https://lean-lang.org/install/manual/). It provides the `lean` and `lake` commands:

```sh
curl -sSf https://elan.lean-lang.org/elan-init.sh | sh
. "$HOME/.elan/env"
elan toolchain install leanprover/lean4:v4.19.0
(cd lean && lean --version && lake --version)
```

The project pins Lean 4.19.0 and uses its standard library, without mathlib. An editor is optional for running checks. For interactive proof inspection, use the [Lean installation guide](https://lean-lang.org/install/) to set up VS Code and its Lean 4 extension.

## Run the example

With the Rust tools installed, run:

```sh
cargo run --locked -p child-authorisation --example school_collection
```

The example prints:

```text
Eve approves Charlie: details=true, authorisation=false
Alice approves Charlie: authorisation=true
Eve wrongly recorded for Charlie: authorisation=true
```

`true` means the rule accepts the supplied request; `false` means it rejects it. Eve's own signed-in parent account passes the incomplete rule but fails the child-specific permission check. Alice's approval passes the repaired rule. The final line shows the remaining assumption: inaccurate school records can still make the repaired rule accept Eve. These are expected results, not test failures.

`make demo` runs the same example when Make is installed.

## Run the checks

After installing all local tools, run the complete suite:

```sh
make check
```

This checks source and documentation style, configuration syntax, Rust formatting, Clippy, tests, Rustdoc, Lean models and their axiom dependencies. A non-zero exit status means a check failed.

For a smaller check, select a target:

| Command | What it checks |
|---|---|
| `cargo test --workspace --locked` | Rust regression tests and doctests; needs only the Rust tools |
| `make rust-lint` | Rust formatting and Clippy |
| `make rust-doc` | Public Rust documentation with warnings denied |
| `make lean-check` | All Lean source modules, automatic axiom checks and negative tests in `lean/test` |
| `make style` | Source comments and Markdown paragraph layout |
| `make config` | TOML, JSON, YAML and shell syntax |

`lake build` inside `lean/` compiles the default library. The standalone `AxiomAudit.lean` inspects imported modules. Use `make lean-check` for discovery and checking of all project modules. The negative tests are expected to be rejected; the command succeeds only when that rejection has the expected cause.

## Install Git hooks

For development, install the [Bun version recorded in package.json](https://bun.com/docs/installation), then install the pinned Lefthook dependency and hooks:

```sh
curl -fsSL https://bun.com/install | bash -s "bun-v1.4.2"
export PATH="$HOME/.bun/bin:$PATH"
bun --version
make hooks-install
```

Bun 1.4.2 and Lefthook 2.1.4 are recorded for this setup. Pre-commit checks staged style and configuration plus affected Rust and Lean code. Commit messages use Conventional Commits with optional `rust`, `lean`, `docs`, `ci`, `deps` or `tooling` scopes. Pre-push runs the full suite. Hooks fail when required tools are missing and do not rewrite or stage files.

Staged style and TOML/JSON checks inspect index contents. YAML, shell and language builds inspect the working tree. Review the staged changes before committing. The comment scanner uses line-based checks rather than a full Rust parser.

## Check dependency advisories

The advisory scan is optional and separate from `make check`. Install cargo-audit, then run it:

```sh
cargo install cargo-audit --locked
make audit
```

This command needs network access to refresh RustSec advisories.

## If a command fails

| Symptom | What to check |
|---|---|
| `cargo` or `rustup` not found | Reopen the terminal or run `. "$HOME/.cargo/env"` |
| `lean`, `lake` or `elan` not found | Reopen the terminal or run `. "$HOME/.elan/env"` |
| `No module named tomllib` | Ensure `python3 --version` reports 3.11 or later |
| Linker or C compiler missing | Install Xcode Command Line Tools on macOS or `build-essential` on Linux |
| Docker cannot connect to its daemon | Start Docker Desktop or the Docker Engine service and retry `docker info` |
| Image `lean-article-checks` not found | Run the Docker build command before the run commands |
| Git reports no repository | Run checks inside the cloned `lean-article` directory |

## What the project implements

| Crate | Acceptance rule |
|---|---|
| `collection-details` | Intentionally incomplete: matching details and signed-in-account membership |
| `child-authorisation` | Repaired: the shared details rule plus recorded permission for this particular child |
| `collection-types` | Shared account, child, collector, day and recorded-permission types |

The details rule checks that the approving account appears in the supplied signed-in-parent list, the child and collector match the request, and both the request and approval refer to today. The repaired rule reuses those checks and adds the account-child permission lookup.

## What Lean establishes

`Collection/Rules.lean` defines executable Boolean models for both Rust rules and proves their acceptance characterisations. `SuppliedInputRequirement` retains the child, collector and day obligations while naming its limited scope: it concerns the supplied inputs and the account named as approver. The repaired rule meets this requirement under `RecordsFaithful`: each recorded permission implies actual permission. Missing entries can deny legitimate requests; the safety theorem requires no false permissions. The separate `RecordsComplete` premise requires every actual permission to be recorded. `supplied_requirement_accepted` proves acceptance of requests satisfying the supplied-input requirement under that completeness premise. Neither premise is established by the checker.

`Collection/Examples.lean` proves Eve passes the details rule, violates the requirement, and is rejected by the repaired rule with accurate records. A positive Alice example instantiates the conditional theorem for a legitimate approval. It also proves that bad records allow Eve and cannot satisfy the faithfulness premise. The conditional theorem remains valid; its premise cannot be supplied for that state.

## Evidence boundary

The Lean definitions are manually written models of the Rust functions. Both use list membership, equality and conjunction. The Rust named `RecordedAuthorisation` maps to an account–child pair in Lean. Rust's `u64` identifiers map to Lean naturals within the `u64` range; neither implementation performs ID arithmetic. The models check both date equalities, including the requested date.

Rust regression tests and manual source review provide limited evidence of correspondence, but there is no verified Rust-to-Lean translation, compiler theorem or theorem about the deployed executable. The Lean results establish properties of the Lean models. Authentication, approval provenance, the real date, permission-record maintenance and release of a child remain outside these examples. A caller must authenticate the supplied approval; matching an account ID is not authentication. A separate teaching `Submission` wrapper carries a submitter but delegates to the unchanged checker. Lean proves that changing this submitter cannot change acceptance; Rust exercises the same boundary. Eve can supply an approval naming signed-in Alice and pass the rule. This does not establish Alice’s consent. The wrapper is not an authenticated endpoint. Actual authority is a separately supplied relation, not a fact established by the checker.

These examples use no cryptographic proof protocol. They illustrate valid formal proofs of supplied statements and the additional obligations needed to apply those statements to running software.

The numeric examples use Alice account 1, Eve account 2, Charlie child 10 and another child 20. Day 42 is an opaque example value, not a calendar conversion. The signed-in and permission lists are unbounded supplied inputs; evaluation scans them linearly, allocates no memory and provides no production resource limit.

The automatic axiom audit visits every declaration in every `Collection` source module, discovered and built from the source tree, including unused axioms and declarations outside the `Collection` namespace. Negative tests separately check rejection of unlisted theorems and unused axioms. Compiler-generated and other unsafe execution declarations, opaque declarations and execution overrides are reported for review, rather than rejected. The audit allows only the standard Lean foundations `propext`, `Classical.choice` and `Quot.sound`; the current proofs use only the first and third. The `Collection` library uses no added logical axioms or proof placeholders. Deliberately forbidden tests are excluded from the library build and must fail their separate checks.
