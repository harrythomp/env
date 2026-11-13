{ pkgs, lib, config, ... }:

let
    defaultUser = "radicale";
    cfg = config.env.homeServer.services.radicale;
    radicaleUser = cfg.user;

    radicaleImage = pkgs.dockerTools.pullImage {
        imageName = "tomsquest/docker-radicale";
        imageDigest = "sha256:2f215d0e6a78ff68c280975af6ce580b05976f70c62b51640397e3eb5a7aa0e9";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-DcxBeMycMqXtNGME11IB/HrIOWERyLL3LoiSpLk3WY0="
            else if pkgs.go.GOARCH == "arm64" then "sha256-j3HMdZWgFrLQCvsYG4ZPJiFjQOkDbT6m0sjK9Tr5h7k="
            else "";
        finalImageName = "tomsquest/docker-radicale";
        finalImageTag = "3.9.0.0";
    };
in
{
    options.env.homeServer.services.radicale = {

        enable = lib.mkEnableOption "radicale";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/radicale";
        };

        configLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/config";
        };

        dataLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/data";
        };

        backupLocations = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ cfg.configLocation cfg.dataLocation ];
        };

        backup = lib.mkOption {
            type = lib.types.bool;
            default = config.env.homeServer.backup;
        };

        user = lib.mkOption {
            type = lib.types.str;
            default = defaultUser;
        };

    };

    config = lib.mkIf cfg.enable {

        users = lib.mkIf (cfg.user == defaultUser) {
            groups.${defaultUser} = {};
            users.${defaultUser} = {
                isSystemUser = true;
                group = defaultUser;
                description = "Radicale service runner";
                linger = true;
                home = cfg.serviceLocation;
                createHome = true;
                autoSubUidGidRange = true;
            };
        };

        virtualisation.oci-containers.containers = {
            radicale = {
                image = "${radicaleImage.imageName}:${radicaleImage.imageTag}";
                imageFile = radicaleImage;
                volumes = [
                    "${cfg.configLocation}:/config:ro"
                    "${cfg.dataLocation}:/data:rw"
                ];
                ports = [
                    "5232:5232/tcp"
                ];
                log-driver = "journald";
                extraOptions = [
                    "--cap-add=CHOWN"
                    "--cap-add=KILL"
                    "--cap-add=SETGID"
                    "--cap-add=SETUID"
                    "--cap-drop=ALL"
                    "--health-cmd=curl -f http://127.0.0.1:5232 || exit 1"
                    "--health-interval=30s"
                    "--health-retries=3"
                    "--memory=268435456b"
                    "--network-alias=radicale"
                    "--security-opt=no-new-privileges:true"
                ];
                podman.user = radicaleUser;
            };
        };

        env.homeServer.containers = {
            networks = {
                radicale = {
                    containers = [ "radicale" ];
                    user = radicaleUser;
                };
            };
            rootTargets = {
                radicale = {
                    containers = [ "radicale" ];
                    networks = [ "radicale" ];
                };
            };
        };

    };
}
