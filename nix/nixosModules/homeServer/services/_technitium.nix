{ pkgs, lib, config, ... }:

let
    defaultUser = "technitium";
    cfg = config.env.homeServer.services.technitium;

    technitiumImage = pkgs.dockerTools.pullImage {
        imageName = "technitium/dns-server";
        imageDigest = "sha256:eb48ac5c135f4ab936b536f74f853d53e15ab39ef37fdbc9598a089b90d9f245";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-GyovCYNvh5VVuZflbnuddOw9Wy/K2GD0ASZmLTUhqTM="
            else if pkgs.go.GOARCH == "arm64" then "sha256-MHZQrFJ6YM09O3kNGBsnHQsY59exMUAjlpe/BJHTvx8="
            else "";
        finalImageName = "technitium/dns-server";
        finalImageTag = "15.6.2";
    };
in
{
    options.env.homeServer.services.technitium = {

        enable = lib.mkEnableOption "technitium";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/technitium";
        };

        envLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/env";
        };

        configLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/config";
        };

        logLocation = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.serviceLocation}/log";
        };

        backupLocations = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ cfg.envLocation cfg.configLocation ];
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
                description = "Technitium service runner";
                linger = true;
                home = cfg.serviceLocation;
                createHome = true;
                autoSubUidGidRange = true;
            };
        };

        virtualisation.oci-containers.containers = {
            technitium = {
                image = "${technitiumImage.imageName}:${technitiumImage.imageTag}";
                imageFile = technitiumImage;
                environmentFiles = [
                    cfg.envLocation
                ];
                volumes = [
                    "${cfg.configLocation}:/etc/dns:rw"
                    "${cfg.logLocation}:/var/log/technitium/dns:rw"
                ];
                ports = [
                    "5380:5380/tcp" #DNS web console (HTTP)
                  # "53443:53443/tcp" #DNS web console (HTTPS)
                    "53:53/udp" #DNS service
                    "53:53/tcp" #DNS service
                  # "853:853/udp" #DNS-over-QUIC service
                  # "853:853/tcp" #DNS-over-TLS service
                  # "443:443/udp" #DNS-over-HTTPS service (HTTP/3)
                  # "443:443/tcp" #DNS-over-HTTPS service (HTTP/1.1, HTTP/2)
                  # "80:80/tcp" #DNS-over-HTTP service (use with reverse proxy or certbot certificate renewal)
                  # "8053:8053/tcp" #DNS-over-HTTP service (use with reverse proxy)
                  # "67:67/udp" #DHCP service
                ];
                log-driver = "journald";
                extraOptions = [
                    "--health-cmd=curl -f http://127.0.0.1:5380/api/dnsClient/healthCheck | grep '\"status\":\"ok\"'"
                    "--userns=keep-id"
                    "--network=technitium"
                ];
                capabilities = {
                    CAP_NET_BIND_SERVICE = true;
                };
                podman.user = cfg.user;
            };
        };

        systemd.services.podman-technitium = {
            serviceConfig = {
                AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
                CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
            };
        };

        env.homeServer.containers = {
            networks = {
                technitium = {
                    containers = [ "technitium" ];
                    user = cfg.user;
                    disableDNS = true;
                };
            };
            rootTargets = {
                technitium = {
                    containers = [ "technitium" ];
                    networks = [ "technitium" ];
                };
            };
        };

    };
}
