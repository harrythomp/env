inputs: { pkgs, ... }:

let
    unstable-pkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
