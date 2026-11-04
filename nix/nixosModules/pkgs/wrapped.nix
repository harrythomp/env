{ self, ... }@inputs: { config, pkgs, lib, ... }:

let
    dots = self.packages.${pkgs.stdenv.hostPlatform.system}.dots.override {
        host = config.env.dots.host;
        overlay = config.env.dots.overlay;
    };
    packages =
        map
        ({ name, value }: value.override { inherit dots; })
        (
            builtins.filter
            ({ name, value }: name != "dots" && name != "scripts")
            (lib.attrsToList self.packages.${pkgs.stdenv.hostPlatform.system})
        );
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

        environment.systemPackages = packages;

    };

}
