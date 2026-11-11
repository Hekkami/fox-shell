-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon & fox-theme set --skip-wall")
	hl.exec_cmd("env QML_IMPORT_PATH=$HOME/.config/quickshell quickshell")
end)
