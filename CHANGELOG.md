# Changelog


## v1.13

- **Machine-wide, not per-account.** Quarantine, the saved language and the installed copy
  moved from `%LOCALAPPDATA%\Usb-Guard` to `C:\ProgramData\Usb-Guard`. An existing
  per-account folder is moved over on the first run. Every account on the PC now sees the
  same quarantine and the same installed program.

- **The watcher works for every account.** It used to be a `HKCU\...\Run` entry, which only
  covered the account that happened to be elevated when it was installed. It is now a
  scheduled task named `UsbGuard`, registered for the built-in Users group with a logon
  trigger, so it starts for whoever signs in. The old Run entry is removed on install and on
  uninstall.

- After a USB is cleaned, USB-Guard offers to copy itself onto that drive, so the next
  infected PC can be treated by double-clicking the stick.

- **The source is in the repository.** `src/usb-guard.ps1` and `src/pack.ps1` are committed;
  the released `.bat` is what `pack.ps1` produces from that source, and it prints a SHA256
  roundtrip check.

- The update check no longer insists that a downloaded release contain `FromBase64String`,
  so a future release can drop the embedded payload without stranding this version.


## v1.12

- **The program speaks English.** On the first run it asks for a language, **1** for English
  and **2** for Turkish, and every screen follows that choice: the banner tagline, the status
  rows, both menus, all help pages, the scan and cleanup steps, the quarantine screens, the
  yes / no prompts and the watcher popup.

- The choice is written to `%LOCALAPPDATA%\Usb-Guard\lang.txt` and not asked again.
  **Language / Dil** in the advanced submenu changes it later, and the advanced status block
  shows the current language.

- Every visible string now lives in one of two parallel tables looked up by key, so a drive
  label or a file path that happens to read like an interface word is never translated.

- Fixed: the label helper was named `LS`, which PowerShell resolves to its built-in
  `Get-ChildItem` alias before any function, so the status and advanced rows printed their
  values with no labels in front of them.


## v1.11

- **Centering actually works now.** PowerShell variable names are case-insensitive, so the
  local `$w` inside the window-fit code was the same variable as the global `$W` (the block
  width). The left margin computed as `($w - $W - 6) / 2` was therefore always negative and
  silently discarded, and every screen hugged the left edge. The margin is now recomputed
  from the live console width on each redraw, and the banner, the status rows, the menu and
  the hint line all start in the same column.

- The selected menu row's highlight no longer paints the left margin; it covers the block
  only, so the bar is the same width as the banner box.

- A blank line separates the two title lines inside the banner box.


## v1.10

- **Right arrow** opens the help for the highlighted item and **left arrow** goes back.
  F1 is gone.

- Installing to `C:` and installing to a USB are back on the main menu, and the USB item
  names the drive it will write to (`-> K: KINGSTON`) so several plugged-in sticks are not
  a guess. With more than one USB the picker lists letter and label.

- A clean PC scan now says the scan is shallow: it checks the startup points worms use,
  not the whole disk, and does not replace an antivirus.

- The continue prompt accepts Enter, Esc, space, and left arrow only. Other keys no longer
  echo stray letters into the console.

- Status block: the version, PC and antivirus labels are brighter, a blank line frames the
  USB list, and section headings inside a run have space around them.

- An immunized drive now reads **Guarded** in the drive list and in the per-drive summary.


## v1.9

- **Subfolders are scanned too**, two levels deep. Jenxcus-style worms drop a copy of the
  shortcut and the payload into every folder, not only the root, so a root-only scan left
  half the drive infected.

- **Double-extension mimics** (`holiday.jpg.exe`, `report.pdf.scr`) are recognised as
  payload, alongside the folder-icon `.exe` trick.

- **Restore from quarantine.** Every quarantined item is recorded with the path it came
  from. The menu lists past quarantine folders and moves their contents back, with the
  same ` (2)` suffix rule on a name clash.

- **USB execute switch.** One Windows policy value (`Removable Disks: Deny execute access`)
  blocks running `.exe` from any removable drive, so a folder-icon fake cannot start at all.
  Reversible from the same menu; full effect after sign-out.

- **Antivirus row** in the status block: which product is registered and whether its
  protection is on, read from Windows Security Center.

- **Simpler main menu.** Cleaning and the PC scan stay on the first screen; the watcher,
  the script-engine switch, the USB execute switch, restore, and the copy actions moved
  under the advanced submenu.

- **Faster start.** The update check, the PC scan, and the antivirus query now run in a
  background runspace while the menu is already usable. Menu-ready time dropped from about
  nine seconds to roughly one; the rows fill in as their answers arrive.


## v1.8

- Update check on launch: the latest GitHub release tag is compared with the running version.
  A newer release is downloaded from the release asset, verified, swapped in place of the
  running `.bat` (and the installed copy), and USB-Guard restarts. The status row shows
  whether the running version is current or could not be checked. This is the only network
  call the program makes.

- **F1** shows a plain-language explanation of the highlighted menu item; **G** opens the
  GitHub page and **S** the sponsor page in the browser (the console cannot make links clickable).

- Everything is centered as a block: a left margin computed from the window width shifts the
  banner, status rows, menu and hints together.

- Window height grows to fit the content instead of cutting the banner off; width stays 80.


## v1.7 (not published; folded into v1.8)

- Turkish characters render correctly: the launcher now writes the embedded script as UTF-8
  with BOM, which Windows PowerShell 5.1 needs in order to read them properly.

- Window is 80×34 (wider, a little shorter), Consolas 20, 60-column box; menu labels are
  spelled with proper Turkish characters again.

- USB cleanup covers more worm families: hidden container folders named `_`, blank,
  punctuation, `recycle.bin`, or referenced by a malicious shortcut are restored; hidden
  `.vbs .js .jse .wsf .hta .bat .cmd .scr .pif .com` payloads and folder-icon `.exe` mimics
  are moved to quarantine (`%LOCALAPPDATA%\Usb-Guard\quarantine\<date>-usb-<letter>`)
  instead of deleted.

- Data-loss fixes in restore: a root name clash gets a ` (2)` suffix instead of being skipped
  and then deleted with the folder; a folder is removed only when it is empty. Fixed a
  variable-shadowing bug in the step runner that made the `sysvolume\<label>` restore
  silently skip.

- Malicious shortcut detection no longer flags every `.lnk` on the drive; only shortcuts whose
  target or arguments run a script engine, `cmd`, `sysvolume`, or that carry the drive label
  or a hidden folder name.

- Drive label and file system come from `Win32_LogicalDisk`, so the Storage module is no
  longer required. USB hard disks (`DriveType` 3 with `BusType` USB) are listed; the system
  drive never is.

- PC scan adds per-user Winlogon `Shell`, `AppInit_DLLs` and IFEO `Debugger` hijacks of
  Task Manager, Registry Editor, cmd, msconfig, Explorer, mmc, PowerShell, Process Explorer.

- New optional menu item, the script-engine switch: toggles Windows Script Host via
  `HKLM\Software\Microsoft\Windows Script Host\Settings\Enabled`, and the status block
  reports whether the engine is on or off.

- Watcher inspects shortcut targets and arguments before offering cleanup.


## v1.6 (not published; folded into v1.8)

- Bigger interface: the console is switched to Consolas 20 on open, the window grows to
  62×40 and stays centered.

- A blank line between every menu item, status row and step so the screen reads easily.

- Shorter menu labels for fix-all, fix-one-drive, install and remove the watcher, and the
  two copy actions.


## v1.5

- The menu now scans the PC on open and reports either a clean machine or the number of
  remnants found; when remnants exist, cleaning this PC becomes the first menu item.

- PC scan rebuilt as a signature table: running `wscript` / `cscript` / `mshta` and miner
  processes, `Run` / `RunOnce` / Policies `Run`, Winlogon `Shell` / `Userinit`, both Startup
  folders, non-Microsoft scheduled tasks, service `ImagePath` / `ServiceDll`, the PrintMiner
  artifacts (`svcinsty64.exe`, `svctrl64.exe`, `u######.dll`, `wsvcz\`, `C:\Windows \System32`,
  hijacked `DcomLaunch`), Defender exclusions, and Explorer sabotage policies.

- Script search covers `.vbs .vbe .js .jse .wsf .hta` in Temp, AppData, LocalAppData,
  ProgramData, the user profile and Public, one folder deep, content-matched.

- Cleanup runs in order: stop processes, remove services, restore `DcomLaunch`, delete
  autostart entries, unregister tasks, remove exclusions, restore policies, quarantine files.
  Locked files are scheduled for move at reboot.

- USB cleanup stops a worm process holding the drive first, reads shortcut **arguments** as
  well as targets, and restores files from `sysvolume\<label>` and blank-named folders too.

- The status list flags a plugged-in USB as worm-infected when it carries malicious
  shortcuts or a live `sysvolume`.

- Spinner no longer types character by character; each step is ~120 ms faster.

- README rewritten in both languages with a table of what the PC scan looks at.


## v1.4

- New menu option to scan this PC and clean the remnants: it looks at `Run` / `RunOnce`, the
  Startup folder and `Temp` / `AppData` for worm remnants, lists them, and on confirmation
  removes the autostart entries and moves files to quarantine instead of deleting them.

- Signature lines are clickable links (OSC 8) showing the full GitHub and Sponsor URLs.

- Console window shrunk to 62×30 and centered on screen.

- README rewritten in English and Turkish after an editorial review.


## v1.3

- Banner box is computed and centered, so the right border stays aligned regardless of the
  version-string length (it was two characters off).

- Status list truncates drive labels longer than 16 characters to keep the columns aligned.


## v1.2

- Copy-to-USB now asks which drive — or all of them — when several USBs are plugged in.

- Menu labels shortened; copy actions renamed to "USB-Guard'i USB/C:'ye Kopyala".

- Teknesyum signature is shown under the banner on every screen, not only on exit.


## v1.1

- Two-accent neon theme (cyan frame, magenta section headers) instead of a single accent.


## v1.0

- Clean infected USBs: remove malicious `.lnk` shortcuts, restore hidden files, clear the
  `sysvolume` payload, un-hide System + Hidden files.

- Immunize with locked decoy folders (`autorun.inf`, `recycler`, `recycled`, `sysvolume`,
  drive label) carrying a `con..` reserved-name subfolder; Deny ACL on NTFS.

- Already-immunized drives detected and skipped.

- Arrow-key menu, centered window, "immunize all" option.

- Opt-in background watcher that offers to clean an infected USB on insertion.

- Single self-elevating `.bat`, PowerShell compressed with gzip + base64 inside it.
