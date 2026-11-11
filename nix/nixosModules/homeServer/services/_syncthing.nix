{ config, lib, ... }:

let
    cfg = config.env.homeServer.services.syncthing;
    allDevices = builtins.attrNames config.services.syncthing.settings.devices;
    enableFor = devices: builtins.elem config.networking.hostName devices;
    mkFolderFor = devices: path: {
        enable = enableFor devices;
        inherit path devices;
    };
    folderPaths =
        map
            (folder: folder.path)
            (builtins.filter
                (folder: folder.enable)
                (builtins.attrValues config.services.syncthing.settings.folders));
in
{

    options.env.homeServer.services.syncthing = {

        enable = lib.mkEnableOption "syncthing";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/syncthing";
        };

        backupLocations = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = folderPaths;
        };

        backup = lib.mkOption {
            type = lib.types.bool;
            default = config.env.homeServer.backup;
        };

        user = lib.mkOption {
            type = lib.types.str;
            default = "syncthing";
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
                    books = mkFolderFor allDevices "${cfg.serviceLocation}/books";
                    dev = mkFolderFor allDevices "${cfg.serviceLocation}/dev";
                    documents = mkFolderFor allDevices "${cfg.serviceLocation}/documents";
                    games = mkFolderFor allDevices "${cfg.serviceLocation}/games";
                    music = mkFolderFor allDevices "${cfg.serviceLocation}/music";
                    pictures = mkFolderFor allDevices "${cfg.serviceLocation}/pictures";
                    work = mkFolderFor allDevices "${cfg.serviceLocation}/work";
                };
                options = {
                    localAnnounceEnabled = false;
                    globalAnnounceEnabled = false;
                };
            };
            user = cfg.user;
            dataDir = cfg.serviceLocation;
            configDir = "${cfg.serviceLocation}/.local/state/syncthing";
            key = "/run/secrets/syncthing-key";
            cert = "/run/secrets/syncthing-cert";
        };

        systemd.services."syncthing" = {
            partOf = lib.mkForce [ "syncthing-root.target" ];
            wantedBy = lib.mkForce [ "syncthing-root.target" ];
        };

        systemd.targets."syncthing-root" = {
            unitConfig = {
                Description = "syncthing root target";
            };
            wantedBy = [ "multi-user.target" ];
        };

    };

}
