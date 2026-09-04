---@diagnostic disable: undefined-global

-- MONITOR
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

hl.workspace_rule({ workspace = 11, monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = 1, monitor = "eDP-1", default = true })

-- PROGRAMS
local terminal = "kitty"
local fileManager = "nautilus"

-- ENV
hl.env("XCURSOR_PATH", "~/.local/share/icons:~/.icons:/usr/share/icons")
hl.env("XCURSOR_THEME", "ShorekeeperV2")
hl.env("XCURSOR_SIZE", 48)
hl.env("HYPRCURSOR_SIZE", 48)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("QT_STYLE_OVERRIDE", "Darkly")

-- GENERAL
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 7,
		border_size = 1,
		resize_on_border = true,
		layout = "dwindle",
	},
})

-- DECORATION
hl.config({
	decoration = {
		rounding = 6,
		rounding_power = 2,
		active_opacity = 0.8,
		inactive_opacity = 0.7,
		shadow = {
			enabled = true,
			range = 40,
			render_power = 4,
			color = "rgba(00000099)",
		},
		blur = {
			enabled = true,
			size = 2,
			passes = 2,
			vibrancy = 0.0,
			vibrancy_darkness = 0,
			contrast = 1,
			brightness = 1,
			popups = true,
			noise = 0,
		},
	},
})

-- ANIMATIONS
hl.config({ animations = { enabled = true } })

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("spring", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "spring", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "linear", style = "popin 90%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = false })

-- LAYOUTS
hl.config({
	dwindle = { preserve_split = true },
	master = { new_status = "master" },
})

-- MISC
hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

-- INPUT
hl.config({
	input = {
		kb_layout = "us",
		sensitivity = 0,
		follow_mouse = 1,
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
		},
	},
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- KEYBINDS
local mainMod = "SUPER"

-- apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("caelestia shell drawers toggle dashboard"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("caelestia shell drawers toggle session"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("caelestia shell lock lock"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("caelestia shell drawers toggle sidebar"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("caelestia shell drawers toggle bar"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("caelestia shell controlCenter open cheatsheet"))
hl.bind(mainMod .. " + Slash", hl.dsp.exec_cmd("/home/kashmira/.local/bin/combo-pick"))
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd("/home/kashmira/.local/bin/emoji-pick"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd('grim -g "$(slurp -c 00000000 -b 00000088)" - | wl-copy'))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("caelestia shell drawers toggle wallpaperPicker"))
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.exec_cmd("caelestia shell wallpaperTransition next"))
hl.bind(
	"Print",
	hl.dsp.exec_cmd('grim -g "$(slurp -c 00000000 -b 00000088)" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png')
)

-- focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- move window (directional)
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- workspaces 1-9
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = 11 }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.move({ workspace = 11 }))

-- alt-tab (floating)
hl.bind("ALT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind("ALT + SHIFT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
	hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- special workspaces
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + W", hl.dsp.workspace.toggle_special("term"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ workspace = "special:term" }))
hl.bind(mainMod .. " + R", hl.dsp.workspace.toggle_special("scratch1"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.window.move({ workspace = "special:scratch1" }))
hl.bind(mainMod .. " + X", hl.dsp.workspace.toggle_special("scratch2"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.window.move({ workspace = "special:scratch2" }))

-- mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- media / brightness (locked)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- WINDOW RULES
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "scratch-term",
	match = { class = "kitty-scratch" },
	workspace = "special:term",
})

hl.window_rule({
	name = "gnome_calc",
	match = { class = "org.gnome.Calculator" },
	float = true,
	move = { 1528, 29 },
	size = { 360, 616 },
})

hl.window_rule({
	name = "qalculate",
	match = { class = "qalculate-gtk" },
	float = true,
	move = { 1430, 34 },
	size = { 462, 491 },
})

hl.window_rule({
	name = "gnome_clocks",
	match = { class = "org.gnome.clocks" },
	float = true,
	move = { 1549, 12 },
	size = { 360, 325 },
})

hl.window_rule({
	name = "kde_connect_transfer",
	match = { class = "org.kde.kdeconnect.daemon" },
	float = true,
	pin = true,
	size = { 420, 220 },
	move = { 1480, 840 },
})

hl.window_rule({
	name = "pip_float",
	match = { title = "Picture-in-Picture" },
	float = true,
	pin = true,
	move = { 1415, 14 },
	size = { 491, 274 },
})

hl.window_rule({
	name = "kde_connect_app",
	match = { class = "org.kde.kdeconnect.app" },
	float = true,
	size = { 700, 450 },
	move = { 605, 315 },
})

hl.window_rule({
	name = "tv_float",
	match = { workspace = 11 },
	float = true,
	size = { 1600, 900 },
})

-- AUTOSTART
hl.on("hyprland.start", function()
	hl.exec_cmd("caelestia shell -d")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("~/.local/bin/tv-workspace-switch.sh")
	hl.exec_cmd("cliphist")
	hl.exec_cmd("sleep 3 && kbuildsycoca6 --noincremental")
	hl.exec_cmd("udiskie")
	hl.exec_cmd("kitty --class kitty-scratch")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("kdeconnectd")
end)

-- Brain_ShellKeybinds
dofile("/home/kashmira/.config/Brain_Shell/Brain_ShellKeybinds.lua")

-- Dynamic border colors
pcall(dofile, "/home/kashmira/.config/hypr/border_colors.lua")
