inputs: { pkgs, ... }:

{

    users.users.admin = {
        isNormalUser = true;
        description = "Admin";
        extraGroups = [ "wheel" ];
        shell = pkgs.fish;
        initialHashedPassword = "$y$j9T$nAYcvLOEsxnUdar0WkK5L/$U02Vlm9M9E8grzyAHIyDRHaQtDxl3dpB3gg9r/5Alh2";
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkTwql2R/Oqyo0ouSKgXavc/SB8II+iTMnoDpWZHyl3 harry@desktop"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILD3ii2c5ZbbIK9mEpdrZFb99c4INIwtbJb+t/sttgLf harry@laptop"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIERTKOKGOOLk8F1QPSgFkW9XWqigcnq48y/ewjQnqfC0 harry@phone"
        ];
    };

    nix.settings.trusted-users = [
        "admin"
    ];

    programs.fish.enable = true;

}
