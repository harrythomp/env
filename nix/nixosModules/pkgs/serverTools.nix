{ self, ... }: { pkgs, ... }:

{

    imports = [
        self.nixosModules.wrappedTools
    ];

    environment.systemPackages = with pkgs; [
        fzf
        ripgrep
        fastfetch
        gnumake
        git
        zoxide
        unzip
        tldr
        bat
        jq
        socat
        ascii
        wget
        gcc
    ];

}
