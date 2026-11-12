inputs: { lib, config, ... }:

let
    sftpGroup = "sftp-only";
    sftpUsers =
        map
            (user: user.name)
            (builtins.filter
                (user: builtins.elem sftpGroup user.extraGroups)
                (builtins.attrValues config.users.users));
in
{

    users.groups.${sftpGroup} = {};

    systemd.tmpfiles.rules =
        map
            (user: "d /var/lib/${user} 0750 root ${config.users.users.${user}.group} -")
            sftpUsers;

    services.openssh = {
        enable = true;
        ports = [ 22 ];
        openFirewall = false;
        settings = {
            PasswordAuthentication = false;
            AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
            UseDns = true;
            X11Forwarding = false;
            PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
        };
        extraConfig = ''
            Match group ${sftpGroup}
                DisableForwarding yes
                ForceCommand internal-sftp
                ChrootDirectory /var/lib/%u
        '';
    };

}
