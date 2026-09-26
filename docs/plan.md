# Plan — UI Audit (uc), 2026-09-27

Usb-Guard is a console program (cmd + PowerShell 5.1). It has no web, WPF or Avalonia view,
so the standard is applied through the console colour table: the 16 console slots the program
writes are remapped to the owner's tokens at start and restored at exit.

1. Bind to the standard: `setup.js --apply --template benim` (done). Keep
   `teknesyum-ui/theme.tokens.json`; move the unused css/react/wpf/avalonia/winforms output to
   `trash/`.
2. `src/usb-guard.ps1`: `$TK` token table + `Set-Palette` / `Restore-Palette`
   (SetConsoleScreenBufferInfoEx). Slot map: Black→surface, Gray/DarkGray/White→text,
   Cyan/Magenta→renk-1, Green→success, Red→danger-text, Yellow/DarkYellow→warning.
3. `src/build.ps1`: fail the build when `$TK` drifts from `theme.tokens.json`.
4. `tools/tui.ps1`: headless test — contrast of every used slot against its real ground (7:1),
   no unmapped colour name in the source, the table is applied in a real conhost.
5. Screen inventory + real window captures (conhost) of every screen; a fresh subagent looks
   at the images only.
6. Shelf books: depo (`tmp/` in .gitignore), lisans and readme-protokolu (already met),
   kurulum-paneli (decision needed).
7. Report `docs/ui-denetim/2026-09-27.md`, release, install to C:.
