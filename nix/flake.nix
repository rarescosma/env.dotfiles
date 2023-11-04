{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    (let
      overlays = [
        (_: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        })
      ];
    in {
      systems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
      perSystem = {system, ...}: {
        config._module.args.pkgs = import nixpkgs {inherit system overlays;};
        imports = [./packages.nix];
      };
    });
}
