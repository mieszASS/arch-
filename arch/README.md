# GlassArch 0.2 — Liquid Glass (Arch Linux / KDE Plasma 6)

**To źródłowy projekt własnego systemu, nie gotowy obraz ISO.** Jest to rozwojowa edycja Arch Linux z autorskim motywem Plasma 6. Nie zawiera kopii elementów Apple.

## Efekty już przy pierwszym uruchomieniu Live USB

1. Własny styl **GlassArchGlass**: mocno półprzezroczyste górne panele i dock, menu aplikacji Plasma (Kickoff), widgety, KRunner, dymki i część powiadomień.
2. KWin: włączone efekty blur i background contrast, animacje glide / slide / fade / scale.
3. Kvantum: na bazie motywu **KvRoughGlass** z oficjalnego pakietu Arch `kvantum` tworzy własny wariant GlassArchGlass, z przezroczystością okien Qt, rozmyciem i przezroczystymi menu.
4. Konsole: własny przezroczysty profil (`Opacity=0.72`) z rozmyciem.
5. Tapeta GlassArch, górny pasek, dolny dock, Papirus-Dark, BreezeDark.
6. Firefox, Dolphin, Konsole, KDE Connect, Discover, Flatpak.

**Ważne ograniczenie:** efekt "szkła na wszystko" jest niemożliwy do zagwarantowania na każdym oknie Linuksa. Programy GTK, przeglądarki, gry, niektóre aplikacje Flatpak/Qt Quick z własnym renderowaniem mogą nie respektować Kvantum. Wygląd zależy także od sprzętu i sterownika. Live startuje przez SDDM na Wayland; sesja X11 jest dostępna jako alternatywa.

## A. Budowa ISO na Arch/CachyOS

```bash
sudo pacman -Syu --needed archiso rsync
cd GlassArch-0.2-LiquidGlass
sudo ./build.sh
```

Projekt kopiuje profil `releng` i buduje system instalacyjny przez `mkarchiso`. Po sukcesie ISO znajdziesz w `out/`. Budowanie wymaga internetu i wolnej przestrzeni (~20 GB lub więcej). **Nie wykonano budowy kompletnego ISO ani testu uruchomienia w VM w tym środowisku**. Skrypty i XML są sprawdzone statycznie, ale po aktualizacji Arch mogą wystąpić zmiany API/pakietów.

**Bezpieczeństwo:** testuj najpierw jako Live w VM lub na zapasowym pendrivie. Nagranie ISO na pendrive nadpisze jego dane. Archinstall (dostępny w środowisku Live) nie przenosi automatycznie wyglądu GlassArch na dysk; po instalacji Archa potrzebny jest skrypt z punktu B. Nie usuwaj partycji Windows bez kopii zapasowej.

## B. Na już zainstalowanym Arch/CachyOS

Rozpakuj paczkę i w terminalu w katalogu projektu:

```bash
./install-on-arch.sh
```

**Bez `sudo` przed tym skryptem** — o uprawnienia do pacmana zapyta sam. Zainstaluje KDE, niezbędne efekty, motyw i uruchomi konfigurację w aktywnej sesji KDE. Jeśli nie jesteś w KDE, doda autostart konfiguracji na następne logowanie.

Gdy już używasz KDE, możesz ręcznie ponowić aplikację:

```bash
glassarch-setup
```

Skrypt zapisuje kopie istniejącego layoutu paneli i ustawień w `~/.local/share/glassarch/backup-*`, **usuwa stare panele KDE i tworzy własne**. Nie zmienia partycji, bootloadera ani haseł. Nie uruchamiaj go w konsoli roota.

Po aplikacji warto wylogować się i zalogować ponownie, aby otwarte wcześniej aplikacje również zaczęły korzystać z Qt/Kvantum.

## C. Przywrócenie poprzednich ustawień

```bash
glassarch-restore
```

Przywraca ostatni zestaw plików konfiguracyjnych, które istniały przed aktywacją GlassArch; następnie wyloguj się i zaloguj ponownie. Jeśli oryginalny plik nie istniał przed instalacją, nie będzie go w kopii i może być konieczne ręczne wybranie poprzedniego motywu w ustawieniach KDE.

## Co jest wewnątrz

- `build.sh` — generuje ISO z profilu Archiso releng.
- `install-on-arch.sh` — instalacja efektów na obecnym systemie.
- `overlay/usr/share/plasma/desktoptheme/GlassArchGlass` — własne SVG paneli, menu, widgetów.
- `overlay/usr/local/bin/glassarch-setup` — ustawienie KWin, Kvantum, Konsole, layoutu i kopia bezpieczeństwa.
- `overlay/usr/local/bin/glassarch-restore` — cofnięcie ustawień.
- `overlay/etc/systemd/system/glassarch-live-user.service` — tworzy konto Live przed logowaniem do Plasma.
- `overlay/etc/skel/.config` — predefiniowane ustawienia nowych użytkowników.
- `overlay/usr/share/glassarch/plasma-layout.js` — ułożenie docka i górnej belki.

### Jak działa GlassArchGlass

SVG-y stosują format 9-częściowych teł Plasma (KDE KSvg) dla paneli, okien dialogowych i widgetów; dla nieobsługiwanych elementów system korzysta z Breeze. KWin rozmywa przezroczyste elementy, które udostępniają prawidłową informację o regionie rozmycia, a Kvantum nadaje szkło w części aplikacji Qt. Efekt maksymalnie "szklany" może pogorszyć czytelność, dlatego ustawiony jest ciemny kolor tła.

### Dokumentacja

- https://wiki.archlinux.org/title/Archiso
- https://develop.kde.org/docs/plasma/theme/theme-elements/
- https://develop.kde.org/docs/plasma/theme/background-svg/
- https://github.com/tsujan/Kvantum
- https://develop.kde.org/docs/plasma/scripting/api/

**Nie jest to oficjalna dystrybucja Arch ani produkt Apple.** Nazwa projektu i motyw są oryginalne; pliki Kvantum pozostają instalowane z pakietu w systemie, a skrypt użytkownika tworzy jego własną modyfikację podczas konfiguracji.


## D. Budowa obrazu przez przegladarke, bez Linuksa

Zobacz `JAK-ZROBIC-ISO-PRZEZ-PRZEGLADARKE.md`. Workflow `.github/workflows/build-iso.yml` uruchamia `build.sh` w kontenerze Arch Linux na serwerze GitHub, a ISO publikuje w Releases (ewentualnie jako czesci do sklejenia). To nadal build eksperymentalny, ktory wymaga testu.
