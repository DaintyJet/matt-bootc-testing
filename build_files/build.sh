#!/bin/bash

# Local testing podman build -t ghcr.io/daintyjet/matt-bootc-testing:latest .

set -ouex pipefail
echo "keepcache=True" >> /etc/dnf/dnf.conf
# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Base installs
dnf5 install -y tmux zsh nvim git curl fzf tmux dnf5-plugins
dnf5 install -y @kde-desktop-environment sddm
dnf5 group install -y development-tools c-development kde-desktop

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# cp /etc/skel/.oh-my-zsh/templates/zshrc.zsh-template /etc/skel/.zshrc


# I am not so smart...
curl -fsSLo /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 install -y brave-browser

# Languages/Programming
export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
ln -sf /usr/local/cargo/bin/* /usr/bin/

rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf install -y code 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# Possible Fix Suggested by LLM for nuking fstab
if [ -f /etc/fstab ]; then
    sed -i '\|^[^#]*\s/\s|s|^|# |' /etc/fstab
fi

# Graphical
systemctl set-default graphical.target

# Base Boot C
systemctl enable podman.socket
