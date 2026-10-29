inputs: { config, lib, ... }:

let
    cfg = config.env.homeServer.services.syncthing;
    homeServerUser = config.env.homeServer.user;
    syncthingUser = config.services.syncthing.user;
    syncthingUserGroup = config.users.users.${syncthingUser}.group;
    syncthingUserHome = config.users.users.${syncthingUser}.home;
    allDevices = builtins.attrNames config.services.syncthing.settings.devices;
    enableFor = devices: builtins.elem config.networking.hostName devices;
in
{

    options.env.homeServer.services.syncthing = {

        enable = lib.mkEnableOption "syncthing";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/syncthing";
        };

        backup = lib.mkOption {
            type = lib.types.bool;
            default = config.env.homeServer.backup;
        };

    };

    config = lib.mkIf cfg.enable {

        services.syncthing = {
            enable = true;
            settings = {
                devices = {
                    desktop = {
                        id = "XSJUEQO-SMKPQO4-KITNZVH-NQRSYSM-5NPFJ6P-VWWIT5B-VJ65GB2-SRMBLQJ";
                        addresses = [
                            "tcp://desktop:22000"
                            "quic://desktop:22000"
                        ];
                    };
                    laptop = {
                        id = "JL5YEJ2-AEZYV6L-AW3QOB6-OBJ3GHM-DXWPY22-NM635EW-B6QGCC7-3T3G7QL";
                        addresses = [
                            "tcp://laptop:22000"
                            "quic://laptop:22000"
                        ];
                    };
                    pi = {
                        id = "I2ZV5DI-2XD5J3Y-BAVPKS3-34UTSHH-X3B3ETF-5ND5BFY-QEYRGAN-R4LJCQI";
                        addresses = [
                            "tcp://pi:22000"
                            "quic://pi:22000"
                        ];
                    };
                };
                folders = {
                    books = {
                        enable = enableFor allDevices;
                        path = "${cfg.serviceLocation}/books";
                        devices = allDevices;
                    };
                    dev = {
                        enable = enableFor allDevices;
                        path = "${cfg.serviceLocation}/dev";
                        devices = allDevices;
                    };
                    documents = {
                        enable = enableFor allDevices;
                        path = "${cfg.serviceLocation}/documents";
                        devices = allDevices;
                    };
                    games = {
                        enable = enableFor allDevices;
                        path = "${cfg.serviceLocation}/games";
                        devices = allDevices;
                    };
                    music = {
                        enable = enableFor allDevices;
                        path = "${cfg.serviceLocation}/music";
                        devices = allDevices;
                    };
                    pictures = {
                        enable = enableFor allDevices;
                        path = "${cfg.serviceLocation}/pictures";
                        devices = allDevices;
                    };
                    work = {
                        enable = enableFor allDevices;
                        path = "${cfg.serviceLocation}/work";
                        devices = allDevices;
                    };
                };
                options = {
                    localAnnounceEnabled = false;
                    globalAnnounceEnabled = false;
                };
            };
            user = lib.mkDefault homeServerUser;
            group = lib.mkDefault syncthingUserGroup;
            dataDir = syncthingUserHome;
            configDir = "${syncthingUserHome}/.local/state/syncthing";
        };

        systemd.services."syncthing" = {
            partOf = lib.mkForce [ "syncthing-root.target" ];
            wantedBy = lib.mkForce [ "syncthing-root.target" ];
        };

        systemd.targets."syncthing-root" = {
            unitConfig = {
                Description = "Root target";
            };
            wantedBy = [ "multi-user.target" ];
        };

    };

}
