#!/usr/bin/env bash
set -euo pipefail

function tv() {
  kscreen-doctor \
    output.HDMI-A-1.disable \
    output.DP-2.enable \
    output.DP-2.mode.41 \
    output.DP-2.scale.1.35

  # Sound too
  pactl set-default-sink alsa_output.pci-0000_91_00.1.hdmi-stereo-extra1
  pactl set-sink-volume alsa_output.pci-0000_91_00.1.hdmi-stereo-extra1 90%
}

function desk() {
  kscreen-doctor \
    output.HDMI-A-1.enable \
    output.HDMI-A-1.mode.2 \
    output.DP-2.disable

  pactl set-default-sink alsa_output.usb-Samson_Technologies_Samson_Go_Mic-00.analog-stereo
}

# HDMI-A-1 is the desk monitor: if it is on, we are at the desk
HDMI_ON=$(kscreen-doctor --json | jq -r '.outputs[] | select(.name == "HDMI-A-1") | .enabled // false')

if [ "$HDMI_ON" = "true" ]; then
  echo "Switching to TV"
  tv
else
  echo "Switching to desk"
  desk
fi
