inputs: { pkgs, ... }:

let
    unstable-pkgs = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
    };
in
{

    services.udev.packages = with pkgs; [ 
        vial
    ];

    environment.systemPackages = with pkgs; [
        alacritty
        sqlitebrowser
        obsidian
        postman
        zed-editor
        transmission_4-gtk
        qbittorrent
        libreoffice-qt
        hunspell
        hunspellDicts.en_GB-ise
        processing
        loupe
        gimp
        musescore
        firefox
        vlc
        nautilus
        gnome-calculator
        gnome-disk-utility
        file-roller
        seahorse
        gittyup
        warehouse
        mysql-workbench
        xournalpp
        rpi-imager
        feishin
        vial
        chromium
    ] ++ (with unstable-pkgs; [
        ghostty
        bottles
    ]);

}
