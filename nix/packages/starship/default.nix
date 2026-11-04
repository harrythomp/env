{ self, nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    starship = import ./starship.nix;
    dots = self.packages.${system}.dots;
in
pkgs.callPackage starship { inherit dots; }
