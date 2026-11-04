{ self, ... }@inputs:

{

    networking.hostName = "pi";

    # nixpkgs.buildPlatform = "x86_64-linux"; # force system to be cross compiled from x86_64

    imports = [
        inputs.nixos-hardware.nixosModules.raspberry-pi-4

        self.nixosModules.adminUser
        self.nixosModules.base
        self.nixosModules.tailscale
        self.nixosModules.openssh
        self.nixosModules.scripts
        self.nixosModules.serverTools
        self.nixosModules.homeServer
    ];

    boot = {
        tmp.useTmpfs = true;
        kernelParams = [
            "console=ttyS0,115200n8"
            "console=ttyAMA0,115200n8"
            "console=tty0"
        ];
        loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
        };
    };

    hardware.enableRedistributableFirmware = true;
    powerManagement.cpuFreqGovernor = "ondemand";

    env.homeServer = {
        services = {
            syncthing.enable = true;
            immich.enable = true;
            navidrome.enable = true;
            radicale.enable = true;
        };
        backup = true;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.11"; # Did you read the comment?

}
