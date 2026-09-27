# Plan — UI Conversion (uc), teknesyum-ui 0.20.0, 2026-09-27

Usb-Guard is a console program. Every surface it has moves onto the owner's layout: the
console screens, the USB warning popup, the install flow and the window icon.

1. Refresh the layout: `setup.js --apply --template benim` (0 drift). Keep every generated
   folder under `teknesyum-ui/`, `esle.js` checks them.
2. Before captures: every screen at 100/125/150% (console font 16/20/24 px) into
   `docs/ui-denetim/2026-09-27/<ekran>-<olcek>-once.png`.
3. Labels: `$LBL` table in `src/usb-guard.ps1` (brand, support, site, window title) read by
   the banner, footer and title; `src/build.ps1` fails when it drifts from
   `teknesyum-ui/winforms/labels.*.json`.
4. USB warning popup: the system MessageBox becomes a WinForms window drawn from `$TK`
   (surface, text, renk-1 with its on-colour, danger-text), same Yes/No result.
5. Install flow (kurulum-paneli): Install-Watcher and Uninstall-Watcher show a numbered step
   list (number while waiting, ✓ done, ! failed), a progress bar with a percentage, and a
   plain error line. No hidden window, no admin prompt added.
6. Icon: a shield drawn from `$TK` set on the console window (WM_SETICON); no shortcut or exe
   exists, so no shortcut to update.
7. After captures, fresh subagent review, `tools/tui.ps1` extended, `artik.js`, `scan.js`,
   `esle.js --denetle`, preview beside the app, report, release, install, `uc.js --bitti`.
