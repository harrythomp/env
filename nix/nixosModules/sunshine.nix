inputs: { pkgs, lib, config, ... }:

 let
    cfg = config.env.sunshine;
 in
 {

    options.env.sunshine = {
        user = lib.mkOption {
            type = lib.types.str;
        };
    };

    config = {

        environment.systemPackages = with pkgs; [
            sway
            wlr-randr
        ];

        services.sunshine = {
            enable = true;
            autoStart = false;
            openFirewall = false;
        };

        services.udev.extraRules = ''
            # Allows Sunshine to acces /dev/uinput
            KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"

            # Allows Sunshine to access /dev/uhid
            KERNEL=="uhid", TAG+="uaccess"

            # Joypads
            KERNEL=="hidraw*" ATTRS{name}=="Sunshine PS5 (virtual) pad" MODE="0660", TAG+="uaccess"
            SUBSYSTEMS=="input", ATTRS{name}=="Sunshine X-Box One (virtual) pad", MODE="0660", TAG+="uaccess"
            SUBSYSTEMS=="input", ATTRS{name}=="Sunshine gamepad (virtual) motion sensors", MODE="0660", TAG+="uaccess"
            SUBSYSTEMS=="input", ATTRS{name}=="Sunshine Nintendo (virtual) pad", MODE="0660", TAG+="uaccess"
        '';

        systemd.services.sunshine-headless = {
            description = "Sunshine headless";

            serviceConfig = {
                Type = "simple";
                ExecStart = pkgs.writeShellScript "sunshine-headless" ''
                    uid=$(${pkgs.coreutils}/bin/id -u)
                    export XDG_RUNTIME_DIR="/run/user/$uid"
                    export XDG_SESSION_TYPE=wayland
                    export XDG_SESSION_CLASS=user
                    export XDG_CURRENT_DESKTOP=sway
                    export DESKTOP_SESSION=sway
                    export WAYLAND_DISPLAY=wayland-1
                    export DISPLAY=:0

                    export WLR_BACKENDS=headless
                    export WLR_LIBINPUT_NO_DEVICES=1


                    # Launch Sway detached from seatd/logind entirely
                    SEATD_VTBOUND=0 ${pkgs.sway}/bin/sway &

                    ${pkgs.coreutils}/bin/sleep 5

                    ${pkgs.sunshine}/bin/sunshine
                '';
                User = cfg.user;
                SupplementaryGroups = [ "input" ];
            };
        };

    };

}
