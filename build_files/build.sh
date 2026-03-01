#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# build.sh — Main image build script for bluefin-dx-gogo
###############################################################################

# ── Niri (scrollable-tiling Wayland compositor) ──────────────────────────────
dnf5 -y copr enable yalter/niri-git
dnf5 -y copr disable yalter/niri-git
dnf5 -y --enablerepo='copr:copr.fedorainfracloud.org:yalter:niri-git' install niri

# ── DMS + Quickshell (from avengemedia COPRs) ───────────────────────────────
dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y --enablerepo='copr:copr.fedorainfracloud.org:avengemedia:danklinux' \
    install quickshell-git

dnf5 -y copr enable avengemedia/dms-git
dnf5 -y copr disable avengemedia/dms-git
dnf5 -y --enablerepo='copr:copr.fedorainfracloud.org:avengemedia:dms-git' \
    --enablerepo='copr:copr.fedorainfracloud.org:avengemedia:danklinux' \
    install --setopt=install_weak_deps=False \
    dms \
    dms-cli \
    dms-greeter \
    dgop \
    dsearch

# ── Wayland companion tools ─────────────────────────────────────────────────
dnf5 -y install \
    brightnessctl \
    playerctl \
    wl-clipboard \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    greetd \
    greetd-selinux \
    gnome-keyring \
    gnome-keyring-pam \
    foot \
    xwayland-satellite \
    plymouth

# ── Copy system config files ────────────────────────────────────────────────
cp -avf /ctx/system_files/. /

# ── Fix greetd PAM for gnome-keyring (from Zirconium) ───────────────────────
if [ -d /usr/share/quickshell/dms/assets/pam ]; then
    install -Dpm0644 -t /usr/lib/pam.d/ /usr/share/quickshell/dms/assets/pam/*
fi

if [ -f /etc/pam.d/greetd ]; then
    if ! grep -q pam_gnome_keyring /etc/pam.d/greetd; then
        sed -i '/^auth.*sufficient.*pam_succeed_if/a auth       optional     pam_gnome_keyring.so' /etc/pam.d/greetd
        sed -i '/^session.*required.*pam_namespace/a session    optional     pam_gnome_keyring.so auto_start' /etc/pam.d/greetd
    fi
fi

# ── Cleanup ─────────────────────────────────────────────────────────────────
dnf5 clean all
