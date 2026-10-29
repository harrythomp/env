{ self, ... }: { config, ... }:

{

    networking.hostName = "laptop";

    imports = [
        self.nixosModules.harryUser

        self.nixosModules.default
        self.nixosModules.battery
    ];

    env.homeServer = {
        user = "harry";
        services = {
            syncthing = {
                enable = true;
                serviceLocation = config.users.users.${config.env.homeServer.user}.home;
            };
        };
    };

    boot.loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

}
