{ nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    scripts = import ./scripts.nix;
in
pkgs.callPackage scripts {}
