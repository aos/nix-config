{ lib, pkgs, ... }:

let
  display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
  backgroundImage = ./config/sysc.jpg;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      auth.fingerprint.enabled = true;

      background = {
        monitor = "";
        path = "${backgroundImage}";
      };

      "$font" = "Cantarell";

      general = {
        hide_cursor = false;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
          "inputFieldDots, 1, 2, linear"
        ];
      };

      input-field = {
        monitor = "";
        size = "16%, 4%";
        outline_thickness = 3;
        inner_color = "rgba(0, 0, 0, 0.0)";
        outer_color = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
        fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";
        font_color = "rgb(143, 143, 143)";
        fade_on_empty = false;
        rounding = 15;
        font_family = "$font";
        placeholder_text = "Input password...";
        fail_text = "$PAMFAIL";
        dots_spacing = 0.3;
        position = "0, -20";
        halign = "center";
        valign = "center";
      };

      label = [
        # TIME
        {
          monitor = "";
          text = "$TIME";
          font_size = 90;
          font_family = "$font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        # DATE
        {
          monitor = "";
          text = ''cmd[update:60000] date +"%A, %d %B %Y"'';
          font_size = 25;
          font_family = "$font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
        # FINGERPRINT
        {
          monitor = "";
          text = "$FPRINTPROMPT";
          font_size = 14;
          font_family = "$font";
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock --no-fade-in";
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
