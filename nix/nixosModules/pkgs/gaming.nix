inputs: { pkgs, ... }:

{

    programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    environment.extraInit = ''
  export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';

    environment.systemPackages = with pkgs; [
        vesktop
        prismlauncher
        dolphin-emu
        clonehero
        azahar
        olympus
        moonlight-qt
    ];

}
