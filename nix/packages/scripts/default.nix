{ self, nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    scripts = import ./scripts.nix;
    dots = self.packages.${system}.dots;
in
pkgs.callPackage scripts { inherit dots; }
