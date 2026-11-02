# Hyprland Lua API and migration reference

Use this as an orientation guide, **not** a frozen specification. First obtain the actual `hyprctl version`; select that tagged version in the official wiki. The default wiki follows Hyprland's latest Git state, which can differ from Arch's installed package. Also inspect `/usr/share/hypr/stubs` (if installed) and `hyprctl descriptions` for local API and option details.

## Authoritative sources

- [Hyprland 0.57 release](https://hypr.land/news/update57/): `.conf` removed as of 0.57 (October 28, 2026).
- [Core configuration / Lua modules](https://wiki.hypr.land/configuring/core/): file location, `require` behavior, automatic reload, Lua errors, local stubs.
- [Config options](https://wiki.hypr.land/configuring/core/config-options/): `hl.config`, option names, types.
- [Binds](https://wiki.hypr.land/configuring/core/binds/) and [dispatchers](https://wiki.hypr.land/configuring/core/dispatchers/): `hl.bind`, `hl.dsp.*`, bind flags.
- [Monitor configuration](https://wiki.hypr.land/configuring/core/monitors/) and [workspace rules](https://wiki.hypr.land/configuring/core/rules/workspace-rules/).
- [Window rules](https://wiki.hypr.land/configuring/core/rules/window-rules/) and [layer rules](https://wiki.hypr.land/configuring/core/rules/layer-rules/).
- [Animations](https://wiki.hypr.land/configuring/core/animations/), [autostart](https://wiki.hypr.land/configuring/core/autostart/), [keyboard layouts](https://wiki.hypr.land/configuring/core/binds/keyboard-layouts/).
- [Events](https://wiki.hypr.land/configuring/core/advanced-configuration/events/), [Lua utilities](https://wiki.hypr.land/configuring/core/advanced-configuration/lua-utilities/), [hyprctl](https://wiki.hypr.land/configuring/core/advanced-configuration/using-hyprctl/).
- [Official example `hyprland.lua`](https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua): **choose the installed release tag**, not necessarily `main`.
- [Old pre-Lua config documentation (0.54)](https://wiki.hypr.land/0.54.0/Configuring/Start/): read only for interpreting legacy settings.

If Lua Language Server is available, the official Hyprland stubs can provide completions and diagnostics. For a requested editor/LSP setup, configure the **dotfiles workspace** `.luarc.json` with `{"workspace":{"library":["/usr/share/hypr/stubs"]}}` after confirming the path exists; don't create editor settings during unrelated desktop changes.

## Basic patterns (verify against the installed version)

```lua
-- $XDG_CONFIG_HOME/hypr/hyprland.lua
require("config.monitors")
require("config.binds")

hl.config({
    input = {
        kb_layout = "us,ca",
        kb_variant = ",multix",
        kb_options = "grp:alt_shift_toggle",
    },
})

-- Or update a single option:
hl.config({ ["general.border_size"] = 2 })
```

```lua
-- Examples, not a complete personal config:
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.bind("SUPER + Q", hl.dsp.exec_cmd("kitty"))
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
end)
hl.window_rule({ match = { class = "kitty" }, float = true })
hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
```

- The final assignment to a config option wins, and window-rule order matters. Do not accidentally shadow an earlier setting.
- `hl.bind` may take a dispatcher or a Lua function. Put runtime-dependent conditions **inside** the function; otherwise they run only as the config loads.
- Lua bind/event handlers share the compositor's event loop. Never call sleeping or blocking I/O in them.
- A `hyprland.start` listener is for **session startup**, not a general-purpose reload hook. Check existing systemd/UWSM ownership before moving apps into it.
- The user can script more advanced behavior with `hl.on`, state-query APIs, and dynamic dispatchers, but check the installed API before introducing new callback shapes or event names.

## Legacy hyprlang → Lua translation map

| Typical pre-0.55 construct | Lua direction (not a literal conversion rule) |
| --- | --- |
| `general { ... }`, `input { ... }`, `dwindle { ... }` | `hl.config({ general = {...}, input = {...}, dwindle = {...} })`; check changed/removed fields |
| `source = ...` | `require("module.name")` with Lua modules, preserving file order |
| `monitor = ...` | `hl.monitor({ output = ..., mode = ..., position = ..., scale = ... })` |
| `bind`, `bindm`, `binde`, submaps | `hl.bind(...)` with documented dispatchers, flags, submap semantics |
| `windowrule[v2] = ...` | `hl.window_rule({ match = {...}, float = true })` or other documented effect fields; explicit typed values |
| `workspace = ...` | `hl.workspace_rule({ ... })` |
| `layerrule = ...` | `hl.layer_rule({ ... })` |
| `exec-once = ...` | Session-start event or user service, avoiding duplicate processes |
| `env = ...` | `hl.env(...)` where appropriate; take UWSM environment rules into account |
| `bezier` / `animation` | `hl.bezier(...)` / `hl.animation(...)` per matching wiki |

Resolve each old key/flag by the exact wiki and actual behavior. Do not preserve deprecated names mechanically (for example, `dwindle:pseudotile` was removed in 0.55). Migrating from `.conf` is a behavioral refactor, especially for rules and bind dispatchers.

## Live read-only inspection and validation

```sh
hyprctl version
hyprctl configerrors
hyprctl descriptions
hyprctl -j monitors
hyprctl -j devices
hyprctl binds
hyprctl getoption general.border_size
```

Use `luac -p` for syntax without executing Lua. `hyprctl repl '...'` can inspect the running Lua state; prefer read-only expressions. `hyprctl eval '...'` runs Lua against the live compositor and is not a safe generic validator. `hyprctl reload` is a normal manual reload; reserve `reload full-reset` for a genuinely necessary and understood context reset. `hyprctl configerrors` is the definitive *live* check for Hyprland errors but does not replace functional smoke tests.
