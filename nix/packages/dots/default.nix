{ nixpkgs, system, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    dots = import ./dots.nix;
in
pkgs.callPackage dots { host = ""; overlay = ""; }
