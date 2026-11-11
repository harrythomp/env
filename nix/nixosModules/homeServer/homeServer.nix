inputs: { config, lib, pkgs, ... }:

let
    cfg = config.env.homeServer;
    services = map (name: builtins.replaceStrings [ "_" ".nix" ] [ "" "" ] name) (builtins.attrNames (builtins.readDir ./services));
    shouldBackupService = service: cfg.services.${service}.backup && cfg.services.${service}.enable;
    servicesWithBackupEnabled = builtins.filter shouldBackupService services;
in
{

    imports = (map (service: ./services/_${service}.nix) services) ++ [
        ./_containers.nix
    ];

    options.env.homeServer = {

        servicesLocation = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib";
        };

        backup = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };

        resticEnvironmentFile = lib.mkOption {
            type = lib.types.str;
            default = "/run/secrets/restic-env";
        };

    };

    config = lib.mkIf cfg.backup {

        environment.systemPackages = with pkgs; [
            restic
        ];

        users = {
            groups.restic = {};
            users.restic = {
                isSystemUser = true;
                group = "restic";
                description = "Restic backup runner";
            };
        };

        systemd.services.restic-backup = {
            description = "Restic Backup Service";

            serviceConfig = {
                Type = "oneshot";
                User = "restic";
                Group = "restic";
                EnvironmentFile = cfg.resticEnvironmentFile;
                ExecStart =
                    map
                        (service:
                            let
                                filesFrom = pkgs.writeText "${service}-backup-paths.txt" (lib.concatLines cfg.services.${service}.backupLocations);
                            in
                            "${pkgs.restic}/bin/restic backup --files-from ${filesFrom} --tag ${service}"
                        )
                        servicesWithBackupEnabled;

                AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
                CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];

                PrivateTmp = true;
                ProtectSystem = "strict";
                ProtectHome = "read-only";
            };
        };

        systemd.services.restic-backup-wrapper = {
            description = "Restic Backup Wrapper Service";

            serviceConfig = {
                Type = "oneshot";

                ExecStart =
                    (map
                        (service: "${pkgs.systemd}/bin/systemctl stop ${service}-root.target")
                        servicesWithBackupEnabled)
                    ++ [ "${pkgs.systemd}/bin/systemctl start restic-backup --wait" ]
                    ++ (map
                        (service: "${pkgs.systemd}/bin/systemctl start ${service}-root.target")
                        servicesWithBackupEnabled);

                PrivateTmp = true;
                ProtectSystem = "strict";
                ProtectHome = "tmpfs";
            };
        };

        systemd.timers.restic-backup = {
            description = "Restic Backup Timer";
            wantedBy = [ "timers.target" ];

            timerConfig = {
                OnCalendar = "*-*-* 04:00:00";
                Unit = "restic-backup-wrapper.service";
            };
        };

    };

}
