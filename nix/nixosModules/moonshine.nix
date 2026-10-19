inputs: { pkgs, lib, config, ... }:

 let
    unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    cfg = config.env.moonshine;
 in
 {

    options.env.moonshine = {
        user = lib.mkOption {
            type = lib.types.str;
        };
    };

    config = {

        users.groups.moonshine = {};

        environment.systemPackages = with unstable-pkgs; [
            moonshine
        ];

        services.udev.packages = with unstable-pkgs; [
            moonshine
        ];

        hardware.graphics = {
            enable = true;
            extraPackages = with unstable-pkgs; [
                moonshine
            ];
        };

        systemd.services.moonshine = {
            description = "Moonshine";

            environment = {
                MOONSHINE_LOG = "moonshine=info";
            };

            path = with pkgs; [
                xwayland
                flatpak
                dbus
                steam
            ];

            serviceConfig = {
                Type = "simple";
                ExecStart = pkgs.writeShellScript "moonshine-server" ''
                    uid=$(${pkgs.coreutils}/bin/id -u)
                    export XDG_RUNTIME_DIR="/run/user/$uid"
                    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
                    ${unstable-pkgs.moonshine}/bin/moonshine
                '';
                User = cfg.user;
                SupplementaryGroups = [ "input" "video" "moonshine" ];
                DeviceAllow = [
                    "/dev/uinput rw"
                    "/dev/uhid rw"
                    "char-drm rw"
                ];
            };
        };

    };

}
