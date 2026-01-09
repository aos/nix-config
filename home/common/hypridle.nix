{ lib, pkgs, ... }:

let
  lockcmd-bin = pkgs.writeShellScriptBin "swaylock-cmd" ''
    ${pkgs.swaylock-effects}/bin/swaylock \
        --daemonize \
        --submit-on-touch \
    	--clock \
        --timestr '%H:%M' \
        --image=~/.config/sysc.jpg \
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
        --inside-ver-color 00000000

    # --ignore-empty-password \
  '';
  display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
in
{
  home.packages = [ lockcmd-bin ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof swaylock || ${lib.getExe lockcmd-bin}";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = display "on";
        inhibit_sleep = 3;
      };

      listener = [
        {
          timeout = 420;   # 7min
          on-timeout = "notify-send -u critical 'system will be locking soon!'";
        }
        {
          timeout = 480;   # 8min
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;   # 10min
          on-timeout = display "off";
          on-resume = display "on";
        }
        {
          timeout = 720;  # 12min
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
