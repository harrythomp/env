{ self, ... }:

{
        
    imports = [
        self.nixosModules.base
        self.nixosModules.networkmanager
        self.nixosModules.audio
        self.nixosModules.bluetooth
        self.nixosModules.graphics
        self.nixosModules.flatpak
        self.nixosModules.fonts
        self.nixosModules.gvfs
        self.nixosModules.keyring
        self.nixosModules.tailscale
        self.nixosModules.scripts
        self.nixosModules.openssh
        self.nixosModules.sshAgent
        self.nixosModules.docker
        self.nixosModules.printing

        self.nixosModules.apps
        self.nixosModules.gaming
        self.nixosModules.languages
        self.nixosModules.tools

        self.nixosModules.niri
        self.nixosModules.waylandWMExtras
        self.nixosModules.icons

        self.nixosModules.ly

        self.nixosModules.homeServer
    ];

}
