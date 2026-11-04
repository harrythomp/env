{ self, nixpkgs-unstable, system, ... }:

let
    pkgs = import nixpkgs-unstable { inherit system; };
    neovim = import ./neovim.nix;
    dots = self.packages.${system}.dots;
in
pkgs.callPackage neovim { inherit dots; }
