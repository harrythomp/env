{ self, nixpkgs, system, session, ... }:

let
    pkgs = import nixpkgs { inherit system; };
    sessionWrapper = import ./session.nix;
    dots = self.packages.${system}.dots;
    sessionPkg = session.packages.${system}.default;
in
pkgs.callPackage sessionWrapper { session = sessionPkg; inherit dots; }
