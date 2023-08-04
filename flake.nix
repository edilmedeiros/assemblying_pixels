{
  description = "A basic flake for Assemblying Pixels";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # Dev tools
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{nixpkgs, rust-overlay, ...}:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = { config, self', lib, system, ... }:
        let
          cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
          pkgs = import nixpkgs { inherit system; overlays = [rust-overlay.overlays.default];};
        in
          {            
          # Rust package
          packages.default = pkgs.rustPlatform.buildRustPackage {
            inherit (cargoToml.package) name version;
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
          };

          # Rust dev environment
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.treefmt.build.devShell
            ];
            shellHook = (lib.concatStrings [''
              # For rust-analyzer 'hover' tooltips to work.
              export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
              export PS1="\033[33;1mShell 🦀 | \W $> \033[39;0m"
            '' (if pkgs.stdenv.isDarwin then "echo 'Have you heard of NixOS?'" else "export NODE_OPTIONS=--openssl-legacy-provider")]);
            buildInputs =  with pkgs; [
              nodePackages_latest.npm
              nodePackages.prettier
            ];
            nativeBuildInputs = with pkgs; [
              cargo
              cargo-watch
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "wasm32-unknown-unknown" ];
              })
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
