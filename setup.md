## Zoom

`https://zoom.us/client/latest/zoom_amd64.deb`
`https://discord.com/api/download?platform=linux&format=deb`
`https://downloads.slack-edge.com/releases/linux/4.25.0/prod/x64/slack-desktop-4.25.0-amd64.deb`

```
curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt install spotify-client
```

apt install scdaemon

## Treesitter

`nix-shell -p gcc`
`vim`
`TSUninstall all`
`TSInstall all`
