{
  description = "A basic flake for Assemblying Pixels";

  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.follows = "rust-overlay/nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    # flake-parts.follows = "rust-overlay/flake-parts";

    systems.url = "github:nix-systems/default";

    # Dev tools
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = { config, self', pkgs, lib, system, ... }:
        let
          cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
          nonRustDeps = with pkgs; [
            nodePackages_latest.npm
            nodePackages.prettier
          ];
        in
        {
          # Rust package
          packages.default = pkgs.rustPlatform.buildRustPackage {
            inherit (cargoToml.package) name version;
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
          };

          # wasm = rustPlatformWasm.buildRustPackage (packages.default // {
          #   pname = "wasm";

          #   buildPhase = ''
          #     cargo build --release -p wasm --target=wasm32-unknown-unknown
          #   '';
          #   installPhase = ''
          #     mkdir -p $out/lib
          #     cp target/wasm32-unknown-unknown/release/*.wasm $out/lib/
          #   '';
          # });

          # Rust dev environment
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.treefmt.build.devShell
            ];
            shellHook = ''
              # For rust-analyzer 'hover' tooltips to work.
              export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
              export PS1="\033[33;1mShell 🦀 | \W $> \033[39;0m"
            '';
            buildInputs = nonRustDeps;
            nativeBuildInputs = with pkgs; [
              cargo
              cargo-watch
              rustc
              rust-analyzer
              clippy
              cargo-generate
              just
              wasm-pack
            ];
          };

          # Add your auto-formatters here.
          # cf. https://numtide.github.io/treefmt/
          treefmt.config = {
            projectRootFile = "flake.nix";
            programs = {
              nixpkgs-fmt.enable = true;
              rustfmt.enable = true;
              prettier.enable = true;
            };
          };
        };
    };
}
