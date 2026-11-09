{ self, ... }: { config, ... }:

{

    imports = [
        self.nixosModules.sops
    ];

    sops.secrets = {
        tailscale-auth-key = {
            sopsFile = ../../secrets/tailscale.yml;
        };
    };

    services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };

}
