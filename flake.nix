{
  description = "MCreator - Make Minecraft mods, Add-Ons, resource packs, and data packs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.callPackage ./default.nix { };
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/MCreator/MCreator";
        };
      }
    );
}