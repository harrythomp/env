{ self, ... }@inputs: { config, pkgs, lib, ... }:

let
    dots = self.packages.${pkgs.stdenv.hostPlatform.system}.dots.override {
        host = config.env.dots.host;
        overlay = config.env.dots.overlay;
    };
    packages =
        map
        (pkg: pkg.override { inherit dots; })
        (with self.packages.${pkgs.stdenv.hostPlatform.system}; [
            btop
            fish
            neovim
            session
            starship
            tmux
            yazi
        ]);
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

        environment.systemPackages = packages ++ (with pkgs; [
            luaPackages.tree-sitter-cli
        ]);

    };

}
