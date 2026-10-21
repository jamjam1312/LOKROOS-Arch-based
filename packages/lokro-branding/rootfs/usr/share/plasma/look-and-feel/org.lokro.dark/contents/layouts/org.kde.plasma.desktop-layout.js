// SPDX-License-Identifier: GPL-3.0-or-later
// Fresh-user layout for LOKRO OS. Existing user layouts are not migrated here.
var oldPanels = panels();
for (var p = oldPanels.length - 1; p >= 0; --p) {
    oldPanels[p].remove();
}

var panel = new Panel;
panel.location = "bottom";
panel.height = 52;
panel.alignment = "center";
panel.lengthMode = "fill";
panel.hiding = "none";

var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "lokro-os");
panel.addWidget("org.lokro.search");
var pager = panel.addWidget("org.kde.plasma.pager");
pager.currentConfigGroup = ["General"];
pager.writeConfig("displayedText", "Number");
pager.writeConfig("showWindowIcons", "false");
pager.writeConfig("wrapPage", "true");
panel.addWidget("org.kde.plasma.icontasks");
panel.addWidget("org.kde.plasma.marginsseparator");
panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");

var screens = desktops();
for (var i = 0; i < screens.length; ++i) {
    var desktop = screens[i];
    desktop.wallpaperPlugin = "org.lokro.slashes";
    desktop.currentConfigGroup = ["Wallpaper", "org.lokro.slashes", "General"];
    desktop.writeConfig("accentColor", "#f4f4f5");
    var oldHubs = desktop.widgets("org.lokro.hub");
    for (var h = oldHubs.length - 1; h >= 0; --h) {
        oldHubs[h].remove();
    }
    if (i === 0) {
        var hub = desktop.addWidget("org.lokro.hub");
        hub.geometry = "40,40,360,320";
    }
}
