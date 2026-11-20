inputs: { pkgs, ... }:

let
    unstable-pkgs = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; };
in
{

    environment.systemPackages = with pkgs; [
        fuzzel
        playerctl
        pavucontrol
        brightnessctl
        grimblast
        hyprpicker
        wayvnc
        wl-clipboard
        networkmanagerapplet
        vicinae
        waypipe
        weylus
        flameshot
        wooz
        antimicrox
    ] ++ (with unstable-pkgs; [
        noctalia
    ]);

}
