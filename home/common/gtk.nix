{ pkgs, home, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Macchiato-Compact-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        size = "compact";
        accents = [ "blue" ];
        tweaks = [
          "rimless"
          "black"
        ];
      };
    };

    iconTheme = {
      name = "Papirus-Catppuccin";
      package = pkgs.catppuccin-papirus-folders.override { flavor = "macchiato"; };
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 32;

    gtk.enable = true;
  };
}
