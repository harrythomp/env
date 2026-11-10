inputs: { config, ... }:

{

    imports = [
        inputs.sops-nix.nixosModules.default
    ];

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.defaultSopsFile = ../../../secrets/${config.networking.hostName}.yml;

    sops.secrets = {
        "syncthing-key" = {
            owner = config.env.homeServer.services.syncthing.user;
        };
        "syncthing-cert" = {
            owner = config.env.homeServer.services.syncthing.user;
        };
        "tailscale-auth-key" = {
            sopsFile = ../../../secrets/tailscale.yml;
        };
    };

}
