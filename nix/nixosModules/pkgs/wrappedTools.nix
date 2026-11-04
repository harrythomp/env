{ self, ... }@inputs: { config, pkgs, lib, ... }:

let
    self-pkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    dots = self-pkgs.dots.override {
        host = config.env.dots.host;
        overlay = config.env.dots.overlay;
    };
    packages =
        map
        (pkg: pkg.override { inherit dots; })
        (with self-pkgs; [
            btop
            fish
            neovim
            session
            starship
            tmux
            yazi
        ]);
    fish = self-pkgs.fish.override { inherit dots; };
in
{

    options.env.dots = {

        host = lib.mkOption {
            type = lib.types.str;
            default = config.networking.hostName;
        };

        overlay = lib.mkOption {
            type = lib.types.str;
            default = "";
        };

    };

    config = {

        nixpkgs.overlays = [
            (final: prev: { inherit fish; })
        ];

        environment.systemPackages = packages ++ (with pkgs; [
            luaPackages.tree-sitter-cli
        ]);

    };

}
