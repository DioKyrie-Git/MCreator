{
  description = "MCreator - Make Minecraft mods, Add-Ons, resource packs, and data packs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.callPackage ./mcreator.nix { };
          mcreator = pkgs.callPackage ./mcreator.nix { };
        };

        apps.mcreator = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/mcreator";
        };
      }
    );
}