{ self, ... }:

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
        authKeyFile = "/run/secrets/tailscale-auth-key";
    };

}
