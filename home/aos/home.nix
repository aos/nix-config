{ ... }:

{
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;

  home.username = "aos";
  home.homeDirectory = "/home/aos";

  imports = [
    ./pkgs
    ./config
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  news.display = "silent";
}
