{ pkgs, lib, config, ... }:

let
    cfg = config.env.homeServer.services.immich;
    immichUser = cfg.user;
    immichTag = "v3.2.2";
in
{
    options.env.homeServer.services.immich = {

        enable = lib.mkEnableOption "immich";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/immich";
        };

        backup = lib.mkOption {
            type = lib.types.bool;
            default = config.env.homeServer.backup;
        };

        user = lib.mkOption {
            type = lib.types.str;
            default = "immich";
        };

    };

    config = lib.mkIf cfg.enable {

        users = {
            groups.immich = {};
            users.immich = {
                isSystemUser = true;
                group = "immich";
                description = "Immich service runner";
                linger = true;
                home = cfg.serviceLocation;
                createHome = true;
                autoSubUidGidRange = true;
            };
        };

        virtualisation.oci-containers.containers = {

            "immich_machine_learning" = {
                image = "ghcr.io/immich-app/immich-machine-learning:${immichTag}";
                volumes = [
                    "immich_model_cache:/cache:rw"
                ];
                log-driver = "journald";
                extraOptions = [
                    "--network-alias=immich-machine-learning"
                ];
                podman.user = immichUser;
            };

            "immich_postgres" = {
                image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
                environmentFiles = [
                    "${cfg.serviceLocation}/.env"
                ];
                volumes = [
                    "${cfg.serviceLocation}/postgres:/var/lib/postgresql/data:rw"
                ];
                log-driver = "journald";
                extraOptions = [
                    "--network-alias=database"
                    "--shm-size=134217728"
                ];
                podman.user = immichUser;
            };

            "immich_redis" = {
                image = "docker.io/valkey/valkey:9@sha256:3b55fbaa0cd93cf0d9d961f405e4dfcc70efe325e2d84da207a0a8e6d8fde4f9";
                log-driver = "journald";
                extraOptions = [
                    "--health-cmd=redis-cli ping || exit 1"
                    "--network-alias=redis"
                ];
                podman.user = immichUser;
            };

            "immich_server" = {
                image = "ghcr.io/immich-app/immich-server:${immichTag}";
                environmentFiles = [
                    "${cfg.serviceLocation}/.env"
                ];
                volumes = [
                    "/etc/localtime:/etc/localtime:ro"
                    "${cfg.serviceLocation}/library:/data:rw"
                ];
                ports = [
                    "2283:2283/tcp"
                ];
                dependsOn = [
                    "immich_postgres"
                    "immich_redis"
                ];
                log-driver = "journald";
                extraOptions = [
                    "--network-alias=immich-server"
                ];
                podman.user = immichUser;
            };

        };

        env.homeServer.containers = {
            networks = {
                immich = {
                    containers = [ "immich_machine_learning" "immich_postgres" "immich_redis" "immich_server" ];
                    user = immichUser;
                };
            };
            volumes = {
                "immich_model_cache" = {
                    containers = [ "immich_machine_learning" ];
                    user = immichUser;
                };
            };
            rootTargets = {
                immich = {
                    containers = [ "immich_machine_learning" "immich_postgres" "immich_redis" "immich_server" ];
                    networks = [ "immich" ];
                    volumes = [ "immich_model_cache" ];
                };
            };
        };


    };
}
