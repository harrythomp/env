inputs: { pkgs, ... }:

{

    users.users.harry = {
        isNormalUser = true;
        description = "Harry";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        shell = pkgs.fish;
        initialHashedPassword = "$y$j9T$tuXXZtOwfIv6kMkB8dZ811$Gelp7AZRKuI3D9XeneUBHEC9dh3lTZi4QfTardqIth6";
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkTwql2R/Oqyo0ouSKgXavc/SB8II+iTMnoDpWZHyl3 harry@desktop"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILD3ii2c5ZbbIK9mEpdrZFb99c4INIwtbJb+t/sttgLf harry@laptop"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIERTKOKGOOLk8F1QPSgFkW9XWqigcnq48y/ewjQnqfC0 harry@phone"
        ];
    };

    programs.fish.enable = true;

}
