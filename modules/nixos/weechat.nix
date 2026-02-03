{ config, pkgs, lib, ... }:

{
  services.weechat.enable = true;
  programs.screen.screenrc = ''
    multiuser on
    acladd aos # TODO: change to your local user
    term screen-256color
  '';
}

# let
#   weechat = pkgs.weechat.override {
#     configure =
#       { availablePlugins, ... }:
#       {
#         plugins = [
#           availablePlugins.python
#           availablePlugins.perl
#           availablePlugins.lua
#         ];
#       };
#   };
# in
# {
#   environment.systemPackages = [ weechat pkgs.screen ];
#   users.groups.wc = {};
#   users.users.wc = {
#     group = "wc";
#     isNormalUser = true;
#     openssh.authorizedKeys.keyFiles = [
#       ../../sops/keys/aos/authorized_keys
#     ];
#   };
#   systemd.services.weechat = {
#     description = "weechat";
#     after = [ "network.target" ];
#     wantedBy = [ "multi-user.target" ];
# 
#     restartIfChanged = false;
# 
#     path = [ pkgs.rxvt-unicode-unwrapped.terminfo ];
# 
#     serviceConfig = {
#       User = "wc";
#       Group = "wc";
#       RemainAfterExit = true;
#       Type = "simple";
#     };
# 
#     script = "exec ${pkgs.screen}/bin/screen -Dm -S weechat-screen ${weechat}/bin/weechat --dir /var/lib/weechat";
#   };
# }
