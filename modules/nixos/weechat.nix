{ config, pkgs, ... }:

{
  services.weechat = {
    enable = true;
    # This is broken for some reason
    # binary = pkgs.weechat.override {
    #   configure = { availablePlugins, ... }: {
    #     scripts = [ pkgs.weechatScripts.weechat-matrix ];
    #     plugins = builtins.attrValues (availablePlugins // {
    #       python = availablePlugins.python.withPackages (ps: with ps; [
    #         pkgs.weechatScripts.weechat-matrix
    #       ]);
    #     });
    #   };
    # };
  };

  programs.screen = {
    enable = true;
    screenrc = ''
      maptimeout 0
      multiuser on
      acladd wc
    '';
  };

  users.users.wc = {
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [
      ../../sops/keys/aos/authorized_keys
    ];
  };
}
