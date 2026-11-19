{ lib, config, pkgs, ... }:

let
    containerGroups = builtins.attrValues config.env.containerGroups;

    mkNetwork = user: targetName: network:
    let
        dnsFlag = if network.disableDNS then "--disable-dns" else "";
    in
    {
        ${network.serviceName} = {
            path = [ pkgs.podman "/run/wrappers" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStop = "${pkgs.podman}/bin/podman network rm -f ${network.name}";
                User = user;
            };
            script = ''
                podman network inspect ${network.name} || podman network create ${dnsFlag} ${network.name}
            '';
            partOf = [ "${targetName}.target" ];
            wantedBy = [ "${targetName}.target" ];
        };
    };

    mkVolume = user: targetName: volume:
    {
        ${volume.serviceName} = {
            path = [ pkgs.podman "/run/wrappers" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                User = user;
            };
            script = ''
                podman volume inspect ${volume.name} || podman volume create ${volume.name}
            '';
            partOf = [ "${targetName}.target" ];
            wantedBy = [ "${targetName}.target" ];
        };
    };

    mkServiceDependencyPatches = containers: cfg:
    let
        containerServiceNames = map (name: config.virtualisation.oci-containers.containers.${name}.serviceName) containers;
    in
    (lib.genAttrs containerServiceNames (_: {
        after = [ "${cfg.serviceName}.service" ];
        requires = [ "${cfg.serviceName}.service" ];
    }));

    mkServiceRootTargetPatches = targetName: container:
    let
        containerServiceName = config.virtualisation.oci-containers.containers.${container}.serviceName;
    in
    {
        ${containerServiceName} = {
            partOf = [ "${targetName}.target" ];
            wantedBy = [ "${targetName}.target" ];
        };
    };

    mkServices = group:
    let
        networks = builtins.attrValues group.networks;
        volumes = builtins.attrValues group.volumes;
        containers = group.containers;
        user = group.user;
        targetName = group.targetName;
    in
    lib.mkMerge (
        (map (mkNetwork user targetName) networks)
        ++ (map (mkVolume user targetName) volumes)
        ++ (map (mkServiceDependencyPatches containers) networks)
        ++ (map (mkServiceDependencyPatches containers) volumes)
        ++ (map (mkServiceRootTargetPatches targetName) containers)
    );

    mkRootTarget = group:
    {
        ${group.targetName} = {
            unitConfig = {
                Description = "${group.name} root target";
            };
            wantedBy = [ ] ++ (lib.optional group.autoStart "multi-user.target");
        };
    };

    mkOciContainerRootTargetPatches = group: lib.genAttrs (group.containers) (_: {
        autoStart = lib.mkForce false;
    });
in
{

    options.env.containerGroups = lib.mkOption {
        default = {};
        type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
            options = {
                name = lib.mkOption {
                    type = lib.types.str;
                    default = name;
                };

                user = lib.mkOption {
                    type = lib.types.str;
                };

                autoStart = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                };

                targetName = lib.mkOption {
                    type = lib.types.str;
                    default = "${name}-root";
                };

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

                            disableDNS = lib.mkOption {
                                type = lib.types.bool;
                                default = false;
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
                        };
                    }));
                };

                containers = lib.mkOption {
                    default = [];
                    type = lib.types.listOf lib.types.str;
                };
            };

        }));
    };

    config = lib.mkIf (containerGroups != [])
    {

        virtualisation.podman = {
            enable = true;
            autoPrune.enable = true;
        };

        virtualisation.oci-containers.backend = "podman";

        systemd.services = lib.mkMerge (map mkServices containerGroups);

        systemd.targets = lib.mkMerge (map mkRootTarget containerGroups);

        virtualisation.oci-containers.containers = lib.mkMerge (map mkOciContainerRootTargetPatches containerGroups);

    };

}
