{
  description = "Personal website for Josh Callanan";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    gohugo-theme-ananke = {
      url = "github:thenewdynamic/gohugo-theme-ananke";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
      ];
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.website = pkgs.stdenv.mkDerivation {
          name = "website";
          src = ./.;
          buildInputs = [ pkgs.git ];
          buildPhase = ''
            mkdir -p themes
            ln -s ${inputs.gohugo-theme-ananke} themes/ananke
            ${pkgs.hugo}/bin/hugo
          '';
          installPhase = "cp -r public $out";
        };
        devshells.default = {
          packages = [
            pkgs.hugo
            pkgs.nixpkgs-fmt
          ];
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
