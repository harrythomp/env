{ pkgs, lib, config, ... }:

let
    cfg = config.env.homeServer.services.immich;
    immichUser = cfg.user;

    immichMachineLearningImage = pkgs.dockerTools.pullImage {
        imageName = "ghcr.io/immich-app/immich-machine-learning";
        imageDigest = "sha256:14367bfb374b8576ddf49abd67c5ca0190a4c7fcf6303cdad65d7f7bf1a50bc2";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-FUoA2HgRwX2z/Dk6Rdp6EM/sv+yz0AeDBMxZ4ZoOt2s="
            else if pkgs.go.GOARCH == "arm64" then "sha256-YPGcsI6NIlzvti17o/NdGQT3Ff3gOsWOqQtlisWMb3U="
            else "";
        finalImageName = "ghcr.io/immich-app/immich-machine-learning";
        finalImageTag = "v3.3.6";
    };

    immichServerImage = pkgs.dockerTools.pullImage {
        imageName = "ghcr.io/immich-app/immich-server";
        imageDigest = "sha256:e1981983b1c13f6024b57d72e7ecae3342eed1581201ab09fb248932d86c593a";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-14QVW7jfVYqhxv05d/4LNa0sFiTZREcu+uBxUfv4TXs="
            else if pkgs.go.GOARCH == "arm64" then "sha256-d6sfdisHs4Q5oQlKrDH5pGa7af9lxgMDvkGxgjrCafY="
            else "";
        finalImageName = "ghcr.io/immich-app/immich-server";
        finalImageTag = "v3.3.6";
    };

    immichPostgresImage = pkgs.dockerTools.pullImage {
        imageName = "ghcr.io/immich-app/postgres";
        imageDigest = "sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-YNxadMZRLd2Wky6UvZFTcJ+KXFxg51E4zPdEAG7HtPk="
            else if pkgs.go.GOARCH == "arm64" then "sha256-LzO1N6q/D3YWKBSA+Ui15gmHZBZajwvpiXLNF5gcBpI="
            else "";
        finalImageName = "ghcr.io/immich-app/postgres";
        finalImageTag = "14-vectorchord0.4.3-pgvectors0.2.0";
    };

    immichRedisImage = pkgs.dockerTools.pullImage {
        imageName = "docker.io/valkey/valkey";
        imageDigest = "sha256:3add1a336a920ea54770a001ab6feb3da5fceea96a40373a3a2cd469b815f0b7";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-9umptl90X5t2Ny4vSC7Rvu1iP44QnERhGUlRRymnJvQ="
            else if pkgs.go.GOARCH == "arm64" then "sha256-+jtI+aXnABS5T5yaET1LX5LvxNE/2u14LbVK5iyO9DQ="
            else "";
        finalImageName = "docker.io/valkey/valkey";
        finalImageTag = "9";
    };
in
{
    options.env.homeServer.services.immich = {

        enable = lib.mkEnableOption "immich";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/immich";
        };

        postgresLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/postgres";
        };

        libraryLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/library";
        };

        envLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/.env";
        };

        backupLocations = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ cfg.postgresLocation cfg.libraryLocation cfg.envLocation ];
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
                image = "${immichMachineLearningImage.imageName}:${immichMachineLearningImage.imageTag}";
                imageFile = immichMachineLearningImage;
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
                image = "${immichPostgresImage.imageName}:${immichPostgresImage.imageTag}";
                imageFile = immichPostgresImage;
                environmentFiles = [
                    cfg.envLocation
                ];
                volumes = [
                    "${cfg.postgresLocation}:/var/lib/postgresql/data:rw"
                ];
                log-driver = "journald";
                extraOptions = [
                    "--network-alias=database"
                    "--shm-size=134217728"
                ];
                podman.user = immichUser;
            };

            "immich_redis" = {
                image = "${immichRedisImage.imageName}:${immichRedisImage.imageTag}";
                imageFile = immichRedisImage;
                log-driver = "journald";
                extraOptions = [
                    "--health-cmd=redis-cli ping || exit 1"
                    "--network-alias=redis"
                ];
                podman.user = immichUser;
            };

            "immich_server" = {
                image = "${immichServerImage.imageName}:${immichServerImage.imageTag}";
                imageFile = immichServerImage;
                environmentFiles = [
                    cfg.envLocation
                ];
                volumes = [
                    "/etc/localtime:/etc/localtime:ro"
                    "${cfg.libraryLocation}:/data:rw"
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
