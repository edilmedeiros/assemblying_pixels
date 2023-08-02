default:
    @just --list

# Auto-format the source tree
fmt:
    treefmt

# Run 'cargo run' on the project
cargo-run *ARGS:
    cargo run {{ARGS}}

# Run 'cargo watch' to run the project (auto-recompiles)
watch *ARGS:
    cargo watch -x "run -- {{ARGS}}"

nix-run:
	nix build && ./result/bin/assemblying-pixels
