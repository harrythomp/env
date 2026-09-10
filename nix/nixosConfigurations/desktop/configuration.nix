{ self, ... }:

{

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; # qemu emulation as a fallback for cross compiling

    networking.hostName = "desktop";

    imports = [
        self.nixosModules.harryUser

        self.nixosModules.default

        self.nixosModules.memlock
        self.nixosModules.sunshine
    ];

    env.homeServer = {
        user = "harry";

        services = {
            syncthing.enable = true;
        };
    };

    boot.loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
    };

    networking.extraHosts = ''
        127.1.0.1 dev.waffle-planner.local
        127.2.0.1 clean.waffle-planner.local
        127.3.0.1 scratch.waffle-planner.local
    '';

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?

}
