{ self, nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    yazi = import ./yazi.nix;
    dots = self.packages.${system}.dots;
in
pkgs.callPackage yazi { inherit dots; }
