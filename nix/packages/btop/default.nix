{ self, nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    btop = import ./btop.nix;
    dots = self.packages.${system}.dots;
in
pkgs.callPackage btop { inherit dots; }
