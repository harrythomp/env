{ pkgs, lib, config, ... }:

let
    cfg = config.env.homeServer.services.navidrome;
    navidromeUser = cfg.user;

    navidromeImage = pkgs.dockerTools.pullImage {
        imageName = "deluan/navidrome";
        imageDigest = "sha256:38dc2727bfcfd5ede290f8ada114fc90368146f265ae4701ddddbcbe2a44ee52";
        hash =
            if pkgs.go.GOARCH == "amd64" then "sha256-cvjgnX4hHIm0syuUTMr5iI0IpDg2tNCnpfbLAFTJjRc="
            else if pkgs.go.GOARCH == "arm64" then "sha256-dcsfcaPQQ3Bf4LKKx6UVzjIRFvKDn0Mb+yzABNOG3Aw="
            else "";
        finalImageName = "deluan/navidrome";
        finalImageTag = "0.64.2";
    };
in
{
    options.env.homeServer.services.navidrome = {

        enable = lib.mkEnableOption "navidrome";

        serviceLocation = lib.mkOption {
            type = lib.types.str;
            default = "${config.env.homeServer.servicesLocation}/navidrome";
        };

        backup = lib.mkOption {
            type = lib.types.bool;
            default = config.env.homeServer.backup;
        };

        user = lib.mkOption {
            type = lib.types.str;
            default = "navidrome";
        };

    };

    config = lib.mkIf cfg.enable {

        users = {
            groups.navidrome = {};
            users.navidrome = {
                isSystemUser = true;
                group = "navidrome";
                description = "Navidrome service runner";
                linger = true;
                home = cfg.serviceLocation;
                createHome = true;
                autoSubUidGidRange = true;
            };
        };

        virtualisation.oci-containers.containers = {
            navidrome = {
                image = "${navidromeImage.imageName}:${navidromeImage.imageTag}";
                imageFile = navidromeImage;
                volumes = [
                    "${cfg.serviceLocation}/data:/data:rw"
                    "${cfg.serviceLocation}/music:/music:ro"
                ];
                ports = [
                    "4533:4533/tcp"
                ];
                log-driver = "journald";
                extraOptions = [
                    "--userns=keep-id"
                    "--network-alias=navidrome"
                ];
                podman.user = navidromeUser;
            };
        };

        env.homeServer.containers = {
            networks = {
                navidrome = {
                    containers = [ "navidrome" ];
                    user = navidromeUser;
                };
            };
            rootTargets = {
                navidrome = {
                    containers = [ "navidrome" ];
                    networks = [ "navidrome" ];
                };
            };
        };

    };
}
