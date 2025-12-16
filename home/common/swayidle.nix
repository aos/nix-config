{ lib, pkgs, ... }:

let
  lockcmd-bin = pkgs.writeShellScriptBin "swaylock-cmd" ''
    ${pkgs.swaylock-effects}/bin/swaylock \
    	--clock \
        --timestr '%H:%M' \
        --image=~/.config/sysc.jpg \
        --ignore-empty-password \
    	--indicator \
        --indicator-idle-visible \
    	--indicator-radius 200 \
    	--indicator-thickness 7 \
    	--effect-blur 1x2 \
    	--effect-vignette 0.5:0.5 \
    	--ring-color B4BEFE \
    	--key-hl-color A6E3A1 \
        --layout-text-color CDD6F4 \
        --ring-ver-color 89B4FA \
        --text-ver-color 89B4FA \
        --line-ver-color 00000000 \
    	--separator-color 00000000 \
    	--line-color 00000000 \
    	--inside-color 00000000 \
        --inside-ver-color 00000000 \
    	--grace 2 \
    	--fade-in 0.2
  '';
  display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
in
{
  home.packages = [ lockcmd-bin ];

  services.swayidle = {
    enable = true;

    events = [
      { event = "before-sleep"; command = (display "off") + "; " + lib.getExe lockcmd-bin; }
      { event = "after-resume"; command = display "on"; }
      { event = "lock"; command = lib.getExe lockcmd-bin; }
    ];

    timeouts = [
      # 8 min
      { timeout = 480; command = lib.getExe lockcmd-bin; }
      # 30 min
      { timeout = 1000; command = "systemctl suspend"; }
    ];
  };
}
