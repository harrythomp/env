inputs: { config, ... }:

{

    imports = [
        inputs.sops-nix.nixosModules.default
    ];

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.secrets = {

        tailscale-auth-key = {
            sopsFile = ../../secrets/tailscale.yml;
        };

    };

}
