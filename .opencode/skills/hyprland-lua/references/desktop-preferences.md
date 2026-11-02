# Vincent's Hyprland setup: known preferences

These are preferences from past conversations, **not** proof of current files. Inspect the live machine and let its active configuration override stale details. Ask before changing an established choice that conflicts with a new request.

## Environment

- Arch Linux; moved from GNOME to Hyprland, typically through GDM, using an ultrawide monitor.
- Desktop utilities include `kitty`, Waybar, `rofi`, Nautilus, `hyprpaper`, `mako`, and `hyprpolkitagent`. Confirm current installed tools and startup ownership before modifying them.
- OpenCode is the intended agent for applying changes locally.

## Preserve unless the user requests otherwise

- Waybar: workspace indicators on the **left**, focused window title in the **center**, CPU/RAM indicators on the **right** with compact visual representation; **no disk indicator**. Workspace numbers displayed in Japanese numerals.
- Keyboard layouts: US for programming and Canadian Multilingual for French. Last accepted XKB settings were `kb_layout = "us,ca"`, `kb_variant = ",multix"`, `kb_options = "grp:alt_shift_toggle"`. Verify the actual keyboard and variant configuration before a rewrite.
- Previously requested behaviors included macOS-like copy/paste, handy window-resize shortcuts, terminal transparency, Rofi integration for Rider, and manageable notification timeouts. These were topics of customization, not a mandate to reconfigure all of them on every change.
- An earlier obsolete `dwindle:pseudotile` setting was removed after Hyprland 0.55. Do not reintroduce it; preserve any supported `dwindle.preserve_split` setting when migrating.

Keep changes narrowly focused. In particular, Waybar and application configuration files are **not** converted to Lua merely because the Hyprland compositor configuration now is.
