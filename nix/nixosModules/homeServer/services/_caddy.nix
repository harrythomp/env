{ pkgs, lib, config, ... }:

let
    defaultUser = "caddy";
    cfg = config.env.homeServer.services.caddy;

    caddyImage = pkgs.dockerTools.pullImage {
        imageName = "caddy";
        imageDigest = "sha256:4e2425f6009577e7c651010f16679c28f7d12df3e7b1914f941a7a3370746b3c";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-GsF+CxRAtC42ZKq+sSIjd+1QxVMUs8Oev+NSDz5mw+Y="
            else if pkgs.go.GOARCH == "arm64" then "sha256-JKeDkHSQAD/bJrk2MuCXauUVgWfnT0k5JiTeF/u8YeQ="
            else "";
        finalImageName = "caddy";
        finalImageTag = "2.11.9";
    };
in
{
    options.env.homeServer.services.caddy = {

        enable = lib.mkEnableOption "caddy";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/caddy";
        };

        backupLocations = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
        };

        backup = lib.mkOption {
            type = lib.types.bool;
            default = false;
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
                description = "Caddy service runner";
                linger = true;
                home = cfg.serviceLocation;
                createHome = true;
                autoSubUidGidRange = true;
            };
        };

        virtualisation.oci-containers.containers = {
            caddy = 
            let
                config = pkgs.writeTextDir "Caddyfile" ''
                    {
                        auto_https off
                    }

                    http://immich.home {
                        reverse_proxy http://immich.home:2283
                    }

                    http://radicale.home {
                        reverse_proxy http://radicale.home:5232
                    }

                    http://navidrome.home {
                        reverse_proxy http://navidrome.home:4533
                    }

                    http://dns.home {
                        reverse_proxy http://dns.home:5380
                    }
                '';
            in
            {
                image = "${caddyImage.imageName}:${caddyImage.imageTag}";
                imageFile = caddyImage;
                volumes = [
                    "${config}:/etc/caddy:ro"
                    "caddy_data:/data:rw"
                    "caddy_config:/config:rw"
                ];
                ports = [
                    "80:80/tcp"
                ];
                log-driver = "journald";
                extraOptions = [
                    "--network-alias=caddy"
                    "--network=caddy"
                ];
                podman.user = cfg.user;
            };
        };

        systemd.services.podman-caddy = {
            serviceConfig = {
                AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
                CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
            };
        };

        env.homeServer.containers = {
            networks = {
                caddy = {
                    containers = [ "caddy" ];
                    user = cfg.user;
                };
            };
            volumes = {
                "caddy_data" = {
                    containers = [ "caddy" ];
                    user = cfg.user;
                };
                "caddy_config" = {
                    containers = [ "caddy" ];
                    user = cfg.user;
                };
            };
            rootTargets = {
                caddy = {
                    containers = [ "caddy" ];
                    networks = [ "caddy" ];
                    volumes = [ "caddy_data" "caddy_config" ];
                };
            };
        };

    };
}
