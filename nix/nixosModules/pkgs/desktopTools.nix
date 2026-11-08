{ self, ... }@inputs: { pkgs, ... }:

let
    unstable-pkgs = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; };
in
{

    imports = [
        self.nixosModules.unwrappedTools
    ];

    environment.systemPackages = with pkgs; [
        air
        neocities
        fzf
        ripgrep
        pkg-config
        openssl
        fastfetch
        gnumake
        inotify-tools
        nmap
        udiskie
        colorz
        cava
        git-filter-repo
        git
        zoxide
        unzip
        tldr
        mdp
        gtypist
        bat
        jq
        tokei
        caddy
        go-task
        jujutsu
        smartmontools
        chafa
        ffmpeg
        socat
        ascii
        compose2nix
        gcc
        matugen
        sops
        age
        ssh-to-age
    ] ++ (with unstable-pkgs; [
        opencode
    ]);

}
