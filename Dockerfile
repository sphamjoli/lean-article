FROM rust:1.97.1-bookworm@sha256:0e2bcaef56d041a486784e54104a81aebe0da44bd03019bd70bc0401e42e4a97
RUN apt-get update && apt-get install -y --no-install-recommends python3 ruby make elan \
    && rm -rf /var/lib/apt/lists/*
RUN rustup component add rustfmt clippy
ENV ELAN_HOME=/opt/elan
ENV PATH="/opt/elan/bin:${PATH}"
RUN elan toolchain install leanprover/lean4:v4.19.0
WORKDIR /app
COPY Cargo.toml Cargo.lock rust-toolchain.toml Makefile ./
COPY crates ./crates
COPY lean ./lean
COPY scripts ./scripts
COPY README.md lefthook.yml package.json ./
RUN git init -b main && git add . && make check
CMD ["make", "check"]
