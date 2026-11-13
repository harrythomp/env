{ lib, config, pkgs, ... }:

let
    cfg = config.env.homeServer.containers;
    networks = builtins.attrValues cfg.networks;
    rootTargets = builtins.attrValues cfg.rootTargets;
    volumes = builtins.attrValues cfg.volumes;

    mkNetwork = cfg: 
    {
        ${cfg.serviceName} = {
            path = [ pkgs.podman "/run/wrappers" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStop = "${pkgs.podman}/bin/podman network rm -f ${cfg.name}";
                User = cfg.user;
            };
            script = ''
                podman network inspect ${cfg.name} || podman network create ${cfg.name}
            '';
        };
    };

    mkNetworkServicePatches = cfg:
    let
        containerServiceNames = map (name: config.virtualisation.oci-containers.containers.${name}.serviceName) cfg.containers;
    in
    (lib.genAttrs containerServiceNames (_: {
        after = [ "${cfg.serviceName}.service" ];
        requires = [ "${cfg.serviceName}.service" ];
    }));

    mkVolume = cfg: 
    {
        ${cfg.serviceName} = {
            path = [ pkgs.podman "/run/wrappers" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                User = cfg.user;
            };
            script = ''
                podman volume inspect ${cfg.name} || podman volume create ${cfg.name}
            '';
        };
    };

    mkVolumeServicePatches = cfg:
    let
        containerServiceNames = map (name: config.virtualisation.oci-containers.containers.${name}.serviceName) cfg.containers;
    in
    (lib.genAttrs containerServiceNames (_: {
        after = [ "${cfg.serviceName}.service" ];
        requires = [ "${cfg.serviceName}.service" ];
    }));

    mkRootTarget = cfg:
    let
        containerServiceNames = map (name: config.virtualisation.oci-containers.containers.${name}.serviceName) cfg.containers;
        networkServiceNames = map (name: config.env.homeServer.containers.networks.${name}.serviceName) cfg.networks;
    in
    {
        ${cfg.targetName} = {
            unitConfig = {
                Description = "${cfg.name} root target";
            };
            wantedBy = [ ] ++ (lib.optional cfg.autoStart "multi-user.target");
        };
    };

    mkRootTargetServicePatches = cfg:
    let
        containerServiceNames = map (name: config.virtualisation.oci-containers.containers.${name}.serviceName) cfg.containers;
        networkServiceNames = map (name: config.env.homeServer.containers.networks.${name}.serviceName) cfg.networks;
        volumeServiceNames = map (name: config.env.homeServer.containers.volumes.${name}.serviceName) cfg.volumes;
    in
    lib.genAttrs (containerServiceNames ++ networkServiceNames ++ volumeServiceNames) (_: {
        partOf = [ "${cfg.targetName}.target" ];
        wantedBy = [ "${cfg.targetName}.target" ];
    });

    mkRootTargetOciContainerPatches = cfg: lib.genAttrs (cfg.containers) (_: {
        autoStart = lib.mkForce false;
    });
in
{

    options.env.homeServer.containers = {

        networks = lib.mkOption {
            default = {};
            type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
                options = {

                    name = lib.mkOption {
                        type = lib.types.str;
                        default = name;
                    };

                    serviceName = lib.mkOption {
                        type = lib.types.str;
                        default = "podman-network-${name}";
                    };

                    containers = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [];
                    };

                    user = lib.mkOption {
                        type = lib.types.str;
                    };

                };
            }));
        };

        volumes = lib.mkOption {
            default = {};
            type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
                options = {

                    name = lib.mkOption {
                        type = lib.types.str;
                        default = name;
                    };

                    serviceName = lib.mkOption {
                        type = lib.types.str;
                        default = "podman-volume-${name}";
                    };

                    containers = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [];
                    };

                    user = lib.mkOption {
                        type = lib.types.str;
                    };

                };
            }));
        };

        rootTargets = lib.mkOption {
            default = {};
            type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
                options = {

                    name = lib.mkOption {
                        type = lib.types.str;
                        default = name;
                    };

                    targetName = lib.mkOption {
                        type = lib.types.str;
                        default = "${name}-root";
                    };

                    containers = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [];
                    };

                    networks = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [];
                    };

                    volumes = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [];
                    };

                    autoStart = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                    };
                    
                };
            }));
        };

    };

    config = lib.mkIf (cfg.networks != {} || cfg.rootTargets != {} || cfg.volumes != {}) 
    {

        virtualisation.podman = {
            enable = true;
            autoPrune.enable = true;
        };

        virtualisation.oci-containers.backend = "podman";

        systemd.services = lib.mkMerge (
            (map mkNetwork networks)
            ++ (map mkNetworkServicePatches networks)
            ++ (map mkVolume volumes)
            ++ (map mkVolumeServicePatches volumes)
            ++ (map mkRootTargetServicePatches rootTargets)
        );

        systemd.targets = lib.mkMerge (map mkRootTarget rootTargets);

        virtualisation.oci-containers.containers = lib.mkMerge (map mkRootTargetOciContainerPatches rootTargets);

    };

}
