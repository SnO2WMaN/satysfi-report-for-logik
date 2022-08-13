{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    satyxin.url = "github:SnO2WMaN/satyxin";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    satyxin,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
          ];
        };
      in rec {
        packages = rec {
          satysfiDist = pkgs.satyxin.buildSatysfiDist {
            packages = [
              "uline"
              "bibyfi"
              "fss"
              "sno2wman"
              "enumitem"
            ];
          };
          main = pkgs.satyxin.buildDocument {
            inherit satysfiDist;
            satysfiLocal = ./.satysfi/local;

            name = "main";
            src = ./src;
            entrypoint = "main.saty";
          };
        };
        defaultPackage = self.packages."${system}".main;

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
