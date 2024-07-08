#!/bin/bash

# exit from the script if any of the commands fail

system_upgrade() {
  xbps-install -Syu
}

install_base_packages() {
  xbps-install -S \
    void-repo-multilib \
    void-repo-nonfree
  
  xbps-install -S \
    wget \
    time \
    polkit \
    seatd \
    neofetch \
    elogind  \
    alacritty \
    helix \
    dolphin \
    firefox \
    telegram-desktop \
    dbus 

  ln -s /etc/sv/dbus /var/service
  ln -s /etc/sv/polkitd /var/service
  ln -s /etc/sv/seatd /var/service
  usermod -aG _seatd $USER
    
  mkdir -p ~/.local/pkgs/
  cd ~/.local/pkgs/
  git clone https://github.com/void-linux/void-packages.git
  cd void-packages
  ./xbps-src binary-bootstrap
}

install_sounds() {
  xbps-install -S \
    alsa-lib-devel \
    alsa-plugins \
    alsa-tools \
    alsa-utils \
    pavucontrol \
    pulseaudio \
    pipewire-devel \
    alsa-pipewire \
    wireplumber \
    libpulseaudio \
    pulseaudio-utils \
  
  ln -s /etc/sv/alsa /var/service
  sv up alsa

  mkdir -p /etc/alsa/conf.d
  ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d
  ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d
}

setup_chrony() {
  xbps-install -S chrony
  ln -s /etc/sv/chronyd /var/service
  sv up chronyd
}

setup_keyboard_layouts() {
  echo /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
  Identifier "system-keyboard"
  MatchIsKeyboard "on"
  Option "XkbLayout" "us,ru"
  Option "XkbModel" "pc105" 
  Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
  EOF
}

install_fish() {
  xbps-install fish-shell
  fish

  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
  fisher install jorgebucaran/nvm.fish
  fisher install IlanCosman/tide@v5
  chsh -s /usr/bin/fish
  set -U fish_greeting

  tide configure
}

install_drivers() {
  xbps-install -S \
    mesa-dri \
    nvidia
}

install_x11() {
  xbps-install -S \
    xorg \
    xorg-server \
    xrandr \
    xterm \
    xtools \
    libxcb \
    xcb-proto \
    libX11-devel \
    libXft-devel \
    libXinerama-devel \
    xorg-server-xephyr \
    xeyes
}

install_dwm() {
  xbps-install -S \
    dmenu 
  
  cd ~/.config/dwm
  make clean install

  echo ~/.xinitrc << EOF
xrandr -s 1920x1080
~/.config/sbar/sbar &
exec ~/.config/dwm/dwm
  EOF
}

install_i3() {
  xbps-install -S i3lock i3blocks picom i3 i3status

  echo > ~/.xinitrc << EOF
xrandr -s 1920x1080
exec i3
  EOF
}

install_wayland() {
  xbps-install -S \
    wlr-randr \
    wlroots
}

install_hyprland() {
  xbps-install -S \
    foot \
    wofi \
    bemenu \
    Waybar

  cd ~/.local/pkgs/
  git clone https://github.com/Makrennel/hyprland-void.git
  cd hyprland-void
  cat common/shlibs >> ~/.local/pkgs/void-packages/common/shlibs
  cp -r srcpkgs/* ~/.local/pkgs/void-packages/srcpkgs

  cd ~/.local/pkgs/void-packages
  ./xbps-src pkg hyprland
  ./xbps-src pkg xdg-desktop-portal-hyprland
  ./xbps-src pkg hyprland-protocols

  xbps-install -R hostdir/binpkgs hyprland
  xbps-install -R hostdir/binpkgs hyprland-protocols
  xbps-install -R hostdir/binpkgs xdg-desktop-portal-hyprland
}

install_river() {
  xbps-install -S \
    foot \
    river \
    bemenu \
    wofi \
    swaylock \
    Waybar
}

install_fonts() {
  xbps-install -S \
    nerd-fonts-ttf \
    noto-fonts-ttf
}

install_dev_tools() {
  xbps-install -S \
    clang \
    clang-tools-extra \
    llvm \
    cmake \
    ninja \
    bash-language-server

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

# main
system_upgrade
install_base_packages
install_sounds
setup_chrony
install_fish
setup_keyboard_layouts
install_drivers
install_fish

install_x11
install_dwm
install_i3
install_wayland
install_river
install_hyprland
install_fonts

install_dev_tools

