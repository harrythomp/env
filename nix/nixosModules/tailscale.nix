inputs:

{

    services.tailscale = {
        enable = true;
        authKeyFile = "/run/secrets/tailscale-auth-key";
    };

}
