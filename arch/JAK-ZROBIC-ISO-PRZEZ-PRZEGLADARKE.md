# GlassArch 0.3 — wlasny ISO BEZ zainstalowanego Linuxa

Projekt zawiera konfigurację dla GitHub Actions (`.github/workflows/build-iso.yml`). Serwer GitHub uruchomi kontener Arch Linux, użyje oficjalnego archiso, a następnie udostępni wyniki jako załączniki wydania (GitHub Releases). **Ten workflow nie został uruchomiony w tym środowisku, więc nie ma gwarancji ukończenia kompilacji ani prawidłowego startu ISO.**

## Instrukcja na Windows — przez przeglądarkę

1. Zaloguj się na https://github.com (konto GitHub jest potrzebne do zbudowania obrazu).
2. Wejdź na https://github.com/new. Utwórz repozytorium, np. `GlassArch`, jako **Public**. Opcjonalnie zaznacz dodanie README, żeby mieć gałąź `main`.
3. Rozpakuj ZIP z projektem na komputerze. W nowym repozytorium wybierz **Add file → Upload files**, przeciągnij **zawartość rozpakowanego folderu**, a nie sam ZIP. Koniecznie prześlij również folder `.github/workflows` z plikiem `build-iso.yml`. Zatwierdź przyciskiem **Commit changes** na gałęzi głównej. Jeżeli przeglądarka nie przyjmie folderu `.github`, użyj przycisku dodawania nowego pliku i podaj jego nazwę `.github/workflows/build-iso.yml`, a następnie wklej zawartość oryginalnego pliku.
4. Otwórz kartę **Actions**, znajdź **GlassArch - zbuduj ISO online** i wybierz **Run workflow** (gałąź `main`). GitHub musi mieć włączone Actions.
5. Po udanym uruchomieniu otwórz kartę **Releases** repozytorium i najnowsze wydanie `GlassArch 0.3 Liquid Glass - ISO build ...`.
6. Pobierz stamtąd **wszystkie** pliki `.iso.chunk-*`, plik `.iso.sha256` oraz `scal-iso.ps1` do jednego folderu. Jeśli plik `.iso` jest dostępny bez podziału, pobierz go wraz z sumą SHA.
7. Uruchom PowerShell/Terminal w tym folderze i wykonaj:

```powershell
powershell -ExecutionPolicy Bypass -File .\scal-iso.ps1
```

8. Po komunikacie `SHA256 OK` powstanie prawdziwy plik `.iso` gotowy do testu w wirtualnej maszynie lub nagrania przez Rufus.

## Ograniczenia i bezpieczeństwo

- To **projekt źródłowy**, nie załączone ISO; do wykonania potrzebny jest GitHub, Internet i zakończony sukcesem workflow.
- Standardowy runner GitHub ma ograniczoną ilość miejsca. Workflow usuwa zbędne pakiety z runnera, ale budowa może się nie powieść, jeśli zabraknie dysku lub zmienią się pakiety Archa.
- ISO może zająć kilka GB. GitHub Releases dopuszcza pliki poniżej 2 GiB, więc projekt automatycznie dzieli większe obrazy i daje skrypt scalający.
- Zawartość ISO to środowisko Live i archinstall; **Archinstall nie przenosi automatycznie motywu GlassArch na system docelowy**. Instalator z własnym wyglądem wymaga jeszcze dalszej pracy.
- Najpierw uruchom obraz w VirtualBox/maszynie wirtualnej. Przed nagraniem na pendrive zrób kopię jego danych. Nie formatuj partycji Windowsa bez świadomej decyzji i backupu.
- Przed publikacją repozytorium upewnij się, że nie dodano tam przypadkowo prywatnych plików.
