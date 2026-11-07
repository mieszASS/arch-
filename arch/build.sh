#!/usr/bin/env bash
# GlassArch ISO builder. Uruchom na Arch/CachyOS: sudo ./build.sh
set -Eeuo pipefail
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_SOURCE="/usr/share/archiso/configs/releng"
PROFILE="$PROJECT_DIR/build/profile"
WORK="$PROJECT_DIR/build/work"
OUT="$PROJECT_DIR/out"

if (( EUID != 0 )); then
  echo "Błąd: budowanie ISO wymaga uprawnień administratora. Użyj: sudo ./build.sh" >&2
  exit 1
fi
for c in mkarchiso rsync pacman; do
  if ! command -v "$c" >/dev/null 2>&1; then
    echo "Brak narzędzia: $c (zainstaluj: sudo pacman -Syu --needed archiso rsync)" >&2
    exit 1
  fi
done
if [[ ! -f "$PROFILE_SOURCE/profiledef.sh" ]]; then
  echo "Brak profilu releng: $PROFILE_SOURCE. Zainstaluj aktualny pakiet archiso." >&2
  exit 1
fi
if [[ -e "$WORK" ]]; then
  echo "Katalog $WORK już istnieje. Usuń go ręcznie po sprawdzeniu, a potem uruchom ponownie." >&2
  exit 1
fi
mkdir -p "$(dirname "$PROFILE")" "$OUT"
if [[ -e "$PROFILE" ]]; then
  echo "Odświeżam wygenerowany profil build/profile (nie dotykam plików projektu)."
  rm -rf -- "$PROFILE"
fi
cp -a -- "$PROFILE_SOURCE" "$PROFILE"
rsync -a -- "$PROJECT_DIR/overlay/" "$PROFILE/airootfs/"

# Pakiety od archiso plus aplikacje naszej edycji.
cat "$PROJECT_DIR/config/extra-packages.txt" >> "$PROFILE/packages.x86_64"
# Ujednolicenie listy bez powtórzeń i komentarzy (archiso obsługuje też komentarze).
awk 'NF && $1 !~ /^#/ && !seen[$1]++ {print $1}' \
  "$PROFILE/packages.x86_64" > "$PROFILE/packages.x86_64.tmp"
mv -- "$PROFILE/packages.x86_64.tmp" "$PROFILE/packages.x86_64"

# Releng uruchamia roota na tty1. GlassArch uruchamia SDDM z użytkownikiem live.
rm -f -- "$PROFILE/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf"
rm -f -- "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service"
rm -f -- "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/systemd-networkd.service"
mkdir -p "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants"
ln -sfn /usr/lib/systemd/system/NetworkManager.service \
  "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
ln -sfn /usr/lib/systemd/system/sddm.service \
  "$PROFILE/airootfs/etc/systemd/system/display-manager.service"
ln -sfn /usr/lib/systemd/system/graphical.target \
  "$PROFILE/airootfs/etc/systemd/system/default.target"
mkdir -p "$PROFILE/airootfs/etc/systemd/system/graphical.target.wants"
ln -sfn /etc/systemd/system/glassarch-live-user.service \
  "$PROFILE/airootfs/etc/systemd/system/graphical.target.wants/glassarch-live-user.service"

# Specjalna nazwa ISO. Profil releng nadal odpowiada za boot BIOS/UEFI.
cat >> "$PROFILE/profiledef.sh" <<'PROFILEEND'
# GlassArch overrides
iso_name="glassarch"
iso_label="GLASSARCH_$(date +%Y%m)"
iso_publisher="GlassArch Community Remix"
iso_application="GlassArch KDE Plasma Live"
iso_version="$(date +%Y.%m.%d)"
# Archiso domyślnie normalizuje tryby plików overlay do 644/755.
# Skrypty muszą być wykonywalne, a sudoers wymaga bezpiecznego 0440.
file_permissions["/usr/local/bin/glassarch-setup"]="0:0:755"
file_permissions["/usr/local/bin/glassarch-restore"]="0:0:755"
file_permissions["/usr/local/bin/glassarch-live-init"]="0:0:755"
file_permissions["/etc/sudoers.d/99-glassarch-live"]="0:0:440"
PROFILEEND

echo "Buduję ISO GlassArch. Obraz pojawi się w: $OUT"
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
echo "Gotowe — obrazy ISO w: $OUT"
