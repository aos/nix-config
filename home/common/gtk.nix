{
  inputs,
  pkgs,
  home,
  ...
}:

{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "blue";
  };

  gtk = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "blue";
      size = "compact";
      tweaks = [ "black" ];

      icon.enable = true;
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 32;

    gtk.enable = true;
  };
}
