{ self, nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    tmux = import ./tmux.nix;
    dots = self.packages.${system}.dots;
in
pkgs.callPackage tmux { inherit dots; }
