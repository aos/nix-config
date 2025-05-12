#!/usr/bin/env bash

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

CURRENT=$(kscreen-doctor --json | \
  jq -r '.outputs[] | select(.enabled) | .name')

if [ $CURRENT = "DP-2" ]; then
  echo "Switching to desk"
  desk
else
  echo "Switching to TV"
  tv
fi
