Things currently not automated.

1. Create g-r-d system cert via 
```
sudo -u gnome-remote-desktop sh -c 'winpr-makecert -silent -rdp -path ~/.local/share/gnome-remote-desktop tls'
```
(Source - https://gitlab.gnome.org/GNOME/gnome-remote-desktop#tls-key-and-certificate-generation)

2. Enable g-r-d (multi-user, headless)

```
sudo grdctl --system rdp set-tls-key ~gnome-remote-desktop/.local/share/gnome-remote-desktop/tls.key
sudo grdctl --system rdp set-tls-cert ~gnome-remote-desktop/.local/share/gnome-remote-desktop/tls.crt
sudo grdctl --system rdp set-credentials # Enter credentials via standard input
sudo grdctl --system rdp enable # enable rdp (multi-user, headless)
sudo systemctl restart gnome-remote-desktop.service
```

Test all this was successful via ` netstat -lntu | grep 3389` - that port should be open now.