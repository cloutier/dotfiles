---
name: hyprland-lua
description: Create, migrate, edit, debug, and validate Hyprland Lua desktop configurations on Arch Linux. Use for Hyprland 0.55+ and especially 0.57+ keybinds, input, monitors, workspaces, rules, layouts, startup, animations, or custom Lua behavior; also for related Waybar, Rofi, Hyprpaper, and notification configuration changes.
---

# Manage the Hyprland Lua desktop

Work against the user's **actual configuration** on their Arch Linux machine. Support both focused edits and migration of an entire legacy `hyprland.conf` setup. Never assume the current OpenCode working directory is the dotfiles directory.

## Inspect before editing

1. Identify the installed and running versions with `hyprctl version` and, if relevant, `pacman -Q hyprland`. If Hyprland is not running or `hyprctl` is unavailable, say which live checks cannot run. Hyprland **0.57+ does not read legacy `.conf` configs**.
2. Resolve the active entry point: `--config` launch arguments take precedence; otherwise use `${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua`. Inspect symlinks, the entry point, `require(...)` modules, any old `source` chain, and neighboring dotfiles. Check for an existing dotfiles Git repository; do not replace symlinked config files or rewrite their targets accidentally.
3. Identify which app owns the requested setting. Hyprland itself uses Lua; Waybar, Rofi, Hyprpaper, mako, etc. maintain their own formats. Hyprland's Lua migration does **not** convert all companion programs' configs.
4. For Hyprland work, read [references/lua-api.md](references/lua-api.md). For preference-sensitive changes, also read [references/desktop-preferences.md](references/desktop-preferences.md).
5. Record the relevant baseline: `hyprctl configerrors`, `hyprctl -j monitors`, `hyprctl -j devices`, `hyprctl binds`, `hyprctl getoption <section.option>`, or program-specific checks, as appropriate. Avoid dumping unnecessary private machine data.

## Write version-correct changes

- Treat the **installed Hyprland version**, its local `/usr/share/hypr/stubs` (when available), and the **matching version of the official wiki** as the authority. The unversioned wiki and repository `main` may document unreleased or breaking changes. Verify each nontrivial `hl.*` API name, field, argument type, and dispatcher against that version. `hyprctl descriptions` can help confirm option names/types. Never invent compatibility shims or copy hyprlang `bind = ...` into Lua.
- Make the smallest coherent edit. Preserve the user's module organization, local variables, comments, keybindings, preferences, rule order, and current behavior unless specifically requested to change them. Check for duplicate/conflicting binds and options and for rules shadowed later in the file.
- Use native Lua configuration APIs (`hl.config`, `hl.monitor`, `hl.bind`, `hl.window_rule`, `hl.workspace_rule`, `hl.animation`, `hl.on`, etc.) as appropriate, following the reference. `require("config.binds")`-style modules are useful for a large setup, but do not split a small working config merely for style.
- For dynamic keybinds and event handlers, keep Lua callbacks nonblocking: they execute on the compositor event loop. Run external or slow tasks asynchronously (e.g. through `hl.dsp.exec_cmd`/`hl.exec_cmd`) instead of waiting in a callback.
- Preserve startup ownership (systemd/UWSM vs. `hl.on("hyprland.start", ...)`) and avoid launching duplicate daemons. Do not restart/exit Hyprland, change display manager, install packages, delete backups, or change unrelated apps without a request that warrants it.

## Migrate from `.conf` when requested

1. Inventory **all** `source`d files, including nested sources, ordering, custom variables, keybinding families/submaps, rules, monitors, environment, startup commands, and companion-app files.
2. Translate behavior rather than mechanically replacing punctuation. Use the migration map in [references/lua-api.md](references/lua-api.md) and verify syntax with installed-version documentation. Keep the original `.conf` files intact as a fallback/reference; never silently discard commented-out customizations.
3. Build a complete Lua entry point and its `require` modules before switching. Preserve ordering where it controls precedence. If using a third-party converter, treat its output as an **untrusted draft** and review each category and diff.
4. Make sure the actual Hyprland launch path selects the intended `hyprland.lua`. Explain any session-start implications; do not assume changing a file automatically switches an already-running session from `.conf` to `.lua`.

## Validate, apply, recover

1. Before an edit that could affect a live desktop, make a uniquely named, recoverable copy of every file being changed (respecting symlinks), or establish a clearly reversible Git change. Ensure a terminal/TTY recovery route exists for risky monitor, input, startup, and migration edits.
2. Prefer preparing a candidate away from the live config, running `luac -p <candidate.lua>` (and syntax-checking affected Lua modules) **before** the final write, then replacing the target without a partial intermediate state. `luac -p` checks Lua syntax only, **not** the Hyprland API; do not execute a config under ordinary `lua` just to validate it. If `luac` is unavailable, report the missing check rather than installing packages silently.
3. Hyprland usually auto-reloads after the live Lua file changes; use `hyprctl reload` only if necessary. Check `hyprctl configerrors` against the baseline and inspect the specific result with `hyprctl binds`, `getoption`, `monitors`, `devices`, etc. `hyprctl repl` is useful for read-only API inspection; `hyprctl eval` can mutate live state, so use it only when the task calls for that. Do **not** routinely use `hyprctl reload full-reset`.
4. Validate companion programs with their own checkers when available. If errors or lost functionality appear, restore the preserved file(s), allow/reissue a normal reload, and confirm recovery. Never leave a known-broken desktop config behind without clearly informing the user.
5. Finish with: files changed, behavior added/modified, validation actually performed (and unavailable checks), any required logout/restart, and the precise rollback location or Git revision.

## Reference routing

- [references/lua-api.md](references/lua-api.md): official sources, version-aware API patterns, migration map, verification commands. Read for every Hyprland Lua request.
- [references/desktop-preferences.md](references/desktop-preferences.md): the user's previously specified Arch/Hyprland setup and preferences. Read before editing input, shortcuts, bars, desktop utilities, or layout choices; live files still take precedence.
