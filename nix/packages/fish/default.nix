{ self, nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    fish = import ./fish.nix;
    dots = self.packages.${system}.dots;
in
pkgs.callPackage fish { inherit dots; }
