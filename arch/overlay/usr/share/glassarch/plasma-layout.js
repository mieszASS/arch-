// GlassArch 0.2: pierwsze uruchomienie — dock, górna belka, tapeta, motyw.
// Dotychczasowe panele są usuwane dopiero po wykonaniu backupu przez skrypt setup.
(function () {
    theme = "GlassArchGlass";
    var old = panels();
    for (var i = 0; i < old.length; ++i) { old[i].remove(); }

    var top = new Panel();
    top.location = "top";
    top.lengthMode = "fill";
    top.height = 36;
    top.hiding = "none";
    top.addWidget("org.kde.plasma.kickoff");
    var topSpacer = top.addWidget("org.kde.plasma.panelspacer");
    top.addWidget("org.kde.plasma.digitalclock");
    top.addWidget("org.kde.plasma.systemtray");

    var dock = new Panel();
    dock.location = "bottom";
    dock.alignment = "center";
    dock.lengthMode = "fit";
    dock.height = 64;
    dock.hiding = "dodgewindows";
    var tasks = dock.addWidget("org.kde.plasma.icontasks");
    tasks.currentConfigGroup = ["General"];
    tasks.writeConfig("launchers", [
        "applications:org.kde.dolphin.desktop",
        "applications:firefox.desktop",
        "applications:org.kde.konsole.desktop",
        "applications:org.kde.discover.desktop",
        "applications:org.kde.systemsettings.desktop"
    ]);
    tasks.reloadConfig();

    var ds = desktops();
    for (var j = 0; j < ds.length; ++j) {
        ds[j].wallpaperPlugin = "org.kde.image";
        ds[j].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
        ds[j].writeConfig("Image", "file:///usr/share/glassarch/wallpaper.png");
        ds[j].writeConfig("FillMode", 2);
        ds[j].reloadConfig();
    }
    print("GlassArch 0.2: płynne szkło — konfiguracja Plasma zastosowana.");
}());
