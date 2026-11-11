pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property var defaultTheme: ({
    "accent": "#f05653",
    "selection": "#243342",
    "muted": "#394d63",

    "darker_background": "#140808",
    "dark_background": "#210e0e",
    "background": "#2e1313",
    "lighter_background": "#422020",

    "dark_foreground": "#6b839c",
    "foreground": "#d0dfe8",
    "light_foreground": "#e6f0f5",
    "bright_foreground": "#f5fafd",

    "red": "#ff4d4d",
    "orange": "#ff8c42",
    "yellow": "#ffd24d",
    "green": "#4da67d",
    "cyan": "#4dc9ff",
    "blue": "#3d73b3",
    "magenta": "#b34db3",
    "brown": "#8c5340",

    "bright_blue": "#6bb3ff",
    "bright_yellow": "#ffe680",
    "bright_green": "#7de8b8",
    "bright_cyan": "#80dfff",
    "bright_magenta": "#e080e0"
  })

  property var colors: defaultTheme

  FileView {
    path: `${Quickshell.env("HOME")}/.config/fox-themes/generated/quickshell-theme.json`
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      try{
        root.colors = JSON.parse(text());
      } catch (e){
        root.colors = root.defaultTheme
      }
    }
  }

}
