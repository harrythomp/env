inputs: { pkgs, ... }:

let
    unstable-pkgs = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; };
in
{

    imports = [
        "${inputs.nixpkgs-unstable}/nixos/modules/programs/wayland/umbriel.nix"
    ];

    programs.umbriel = {
        enable = true;
        package = unstable-pkgs.umbriel;
        portalPackage = unstable-pkgs.xdg-desktop-portal-umbriel;
    };

}
