#!/usr/bin/env bash
# Instalacja GlassArch Liquid Glass na istniejącym Arch/CachyOS.
# Nie zmienia partycji, bootloadera ani haseł. Dotknie ustawień pulpitu.
set -Eeuo pipefail
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (( EUID == 0 )); then
  echo "Uruchom jako zwykły użytkownik, BEZ sudo." >&2; exit 1
fi
if ! command -v pacman >/dev/null; then
  echo "Wymagany pacman (Arch lub CachyOS)." >&2; exit 1
fi
mapfile -t pkgs < <(awk 'NF && $1 !~ /^#/ {print $1}' "$PROJECT_DIR/config/extra-packages.txt")
echo "GlassArch: aktualizacja pakietów, instalacja KDE/Qt i szklistych efektów."
sudo pacman -Syu --needed "${pkgs[@]}"
SRC="$PROJECT_DIR/overlay"
sudo install -Dm755 "$SRC/usr/local/bin/glassarch-setup" /usr/local/bin/glassarch-setup
sudo install -Dm755 "$SRC/usr/local/bin/glassarch-restore" /usr/local/bin/glassarch-restore
sudo install -Dm644 "$SRC/usr/share/glassarch/plasma-layout.js" /usr/share/glassarch/plasma-layout.js
sudo install -Dm644 "$SRC/usr/share/glassarch/wallpaper.png" /usr/share/glassarch/wallpaper.png
sudo install -Dm644 "$SRC/usr/share/applications/glassarch-setup.desktop" /usr/share/applications/glassarch-setup.desktop
sudo cp -a "$SRC/usr/share/plasma/desktoptheme/GlassArchGlass" /usr/share/plasma/desktoptheme/
sudo install -Dm644 "$SRC/usr/share/glassarch/GlassArch.colors" /usr/share/glassarch/GlassArch.colors
sudo install -Dm644 "$SRC/usr/share/glassarch/GlassArch.profile" /usr/share/glassarch/GlassArch.profile

# Dla aktualnego konta ustawiamy autostart, bez automatycznego uruchamiania sudo w tle.
mkdir -p "$HOME/.config/autostart"
cp -f "$SRC/etc/skel/.config/autostart/glassarch-first-run.desktop" \
 "$HOME/.config/autostart/glassarch-first-run.desktop"
if [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* || "${XDG_CURRENT_DESKTOP:-}" == *Plasma* ]]; then
  glassarch-setup
else
  echo "Gotowe. Przy następnym uruchomieniu sesji KDE Plasma efekt GlassArch włączy się automatycznie."
fi
