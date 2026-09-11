# Changelog


## v1.21

The drive's name comes back, and old decoys stay hidden.

- **Immunity's `autorun.inf` is a locked file now, not a folder.** v1.19 saved the drive's
  name into the volume label, but Explorer still showed the generic "USB Drive (D:)": a root
  `autorun.inf` makes the shell read the display name from that file, and because immunity had
  turned it into a folder the shell could not read it and fell back to the type name. The
  immunity `autorun.inf` is now a small locked file holding only `[autorun]`, so the shell
  reads it, finds nothing to override the label with, and shows the real volume label again.
  It still occupies the `autorun.inf` name and is locked read-only/system/hidden with a Deny
  ACE on NTFS, so a worm cannot drop its own. A folder-shaped `autorun.inf` left by an older
  version is migrated to the file on the next run.

- **A hostile `autorun.inf` is still caught.** Infection detection no longer treats every
  `autorun.inf` file as malware; it flags one only when it carries an `open=`, `shellexecute=`
  or `shell\...` action. The immune file has none, so it is left alone; a real worm's file is
  replaced by the locked one.

- **Old label-named decoys no longer reappear.** When the volume label changed, the decoy
  named after the previous label fell off the skip-list, so the "make files visible" step
  unhid it and it showed up as an undeletable folder. That step now also skips any folder that
  is already immunized — recognised by its reserved `con..` child — so stale decoys stay
  hidden.

- New test: `tools/tar.ps1` covers the file-based immunity, migration from a folder, the
  malicious-`autorun.inf` case and decoy recognition.


## v1.20

The menu stops flickering in a short window.

- **The menu no longer redraws over itself once the console has scrolled.** Every redraw
  started at the row remembered before the first paint. When the list was taller than the
  window the console scrolled, that row went stale, and each keypress painted in the wrong
  place and scrolled again — a steady flicker that only stopped when the window was made
  wider. The starting row is now recomputed from the cursor after every paint, so it stays
  correct however far the view has scrolled.

- **The window is sized before the first paint, not after it.** It used to be measured once
  the menu was already on screen, which meant the first frame did the scrolling that caused
  the drift. If the list still does not fit at the largest window the console allows, the
  blank line between entries is dropped and the list is drawn at half the height.

- **A redraw only happens when something changed.** The loop repainted the whole list before
  every keypress, including keys that moved nothing.


## v1.19

The drive keeps its name.

- **Immunity no longer throws the drive's name away.** Windows shows a removable drive under
  the `label=` line inside `autorun.inf`, ahead of the real volume label. Immunity replaces
  that file with a locked folder of the same name, and until now it simply deleted it — with
  no copy in quarantine — so the name the drive had shown for years disappeared for good.
  The name is now read out of `autorun.inf` before the file is destroyed and written to the
  filesystem's own volume label instead. A volume label is metadata, not a file: a worm
  cannot hijack it by dropping an `autorun.inf`, so the name survives every later cleanup.

- **A drive with no name is offered one.** When the volume label is empty and `autorun.inf`
  carried nothing to recover, USB-Guard asks once, in a single line, whether you want to name
  the drive, and writes what you type. Esc or N skips it.

- The name is sanitised before it is written: control characters, path and wildcard
  characters and shell metacharacters are stripped, and the length is capped at 11 characters
  on FAT/exFAT and 32 on NTFS. The value comes from a file an attacker controls, so it is
  never passed to a shell — the label is set through `SetVolumeLabelW`.

- New test: `tools/tlabel.ps1` covers the parsing, the sanitiser and the case where
  `autorun.inf` is already the locked folder.


## v1.18

A screen-and-keyboard release. Nothing changed in what USB-Guard detects.

- **The Yes/No questions wait for an answer again.** A key pressed earlier — an Enter still
  in the buffer from the menu — was consumed by the prompt, so the copy-to-USB question
  answered itself and moved on. The buffer is now drained first, and a single keystroke
  (E/H, Y/N) decides; Enter and Esc mean no.

- **Half as much scrolling.** The finish screen for one drive went from about 47 lines to 27:
  the blank line after every step, the empty lines under the section headings, and the
  explanation under the copy question are gone.

- **The spinner no longer freezes.** Its four frames all played before the work started, so
  what you actually watched was a stopped `\`. There is no animation now — the label, then
  the result.

- **Long messages fit the window.** The text after a PC scan, the two side-effect notes and
  the quarantine and tip lines are wrapped to the box width instead of running past it. The
  three-part scan note became one sentence.


## v1.17

USB-Guard used to decide what a file was by looking at its name. This release makes it read
the file.

- **A hidden file is judged by its first 4 KB, not its extension.** A hidden `invoice.pdf`
  beginning with `MZ`, or a `notes.txt` that is really encoded VBScript (`#@~^`), now counts
  as a payload. This closes a hole in USB-Guard itself: when it emptied a worm's hidden
  folder it decided what to quarantine from the extension alone, so a disguised executable
  was carried out of the folder and dropped in the root of your drive.

- **The arguments of a malicious shortcut are followed.** The files a bad `.lnk` actually
  names are resolved on the same drive. A payload goes to quarantine; your real document
  only loses its System + Hidden attributes and stays where it is. `.lnk` targets now also
  match `/r`, `%comspec%`, `%windir%`, `conhost`, `msiexec`, `regsvr32`, `certutil`,
  `bitsadmin`, `forfiles` and `wmic` — the launchers Raspberry Robin and its relatives use.

- **Folders disguised as system objects are opened up.** A hidden folder whose `desktop.ini`
  carries the Recycle Bin, This PC, Control Panel, Search or "God Mode" CLSID, or whose name
  ends in `.{GUID}`, is treated as a worm container. `RECYCLER`, `RECYCLED`, `_recycle` and
  `$RECYCLE.BIN.` were added to the container names.

- **`System Volume Information` and `$RECYCLE.BIN` are checked.** Neither folder is ever
  deleted, but a file inside that is neither a genuine recycle-bin entry nor a known Windows
  file, and that looks executable, is quarantined. Raspberry Robin and PlugX both hide there.

- **Right-to-left override names are caught.** `resim<RTLO>gpj.exe` shows up in Explorer as
  `resim exe.jpg`; USB-Guard reads the real name.

- The USB scan goes three folder levels deep instead of two, up to 20 000 files.
  `.url` and `.scf` were added to the payload extensions.

- **A drive can now be Partially Guarded.** Immunity is a set of decoy folders; if some are
  in place and some are not — a name added in a later version, or one that was removed — the
  status says so instead of claiming the drive is protected. Fully immunized reads
  **Guarded**, none reads **Not Guarded**.

- **A bug that had been there since immunity was written.** The check for "is this hidden
  folder named in a shortcut" used a regular expression with an unclosed character class and
  a trailing backslash. It threw on every hidden folder that was not already recognised by
  name, so those folders were silently skipped.

On the PC side:

- Defender exclusions are read from the policy branch as well as the normal one, and
  extension and process exclusions are checked too, not only paths.

- `UserInitMprLogonScript` and a redirected `User Shell Folders\Startup` are reported.

- A signed program sitting in a user-writable folder with an **unsigned DLL beside it** is
  reported as sideloading — the way Mustang Panda runs PlugX. Signature checking used to
  clear such a program outright.

- The script sweep goes two subfolder levels deep instead of one, covers `Public\Documents`
  and `Users\Default`, and raises its directory cap from 400 to 1500.

- The PowerShell pattern was narrowed: a bare `bypass` no longer counts on its own, only
  together with a hidden window, an encoded command, or a path in Temp / AppData /
  ProgramData / Public. Fewer false positives on normal installers.

- The README now says plainly what USB-Guard does **not** do: BadUSB / HID, file infectors
  such as Sality and Ramnit, and payloads inside ISO / IMG / VHD images.


## v1.16

- **The language screen takes the arrow keys.** Up and down move the highlight, Enter
  confirms, and `1` / `2` still pick English or Turkish straight away, the way the rest of
  the menus work.

- The copy of `USB-Guard.bat` in the repository is now byte-identical to the released file.
  Git was rewriting its line endings on commit, so its SHA256 did not match the one in the
  release notes.

- The released file is on VirusTotal and clean; the report is linked in the README.


## v1.15

- **The scan showed one finding when it had found several.** The result of the scan step was
  piped through `Select-Object -Last 1`, so however many remnants were found, only the last
  one was ever listed, while the status row above kept reporting the real number. Two meant
  two; fifteen means fifteen. Findings are numbered now.

- **Ignore a finding.** At the scan prompt you can type the numbers of the findings you want
  to keep, e.g. `1,3`. They go into `C:\ProgramData\Usb-Guard\ignore.txt` and are not
  listed or counted again. **Clear The Ignore List** in the advanced menu undoes that, and
  the advanced status block shows how many are ignored.

- Version 1.12 could not update itself to 1.14: its updater refuses any download that does
  not contain the word `FromBase64String`, and 1.14 dropped the packing. The word is now in
  the file's header comment, so 1.12 installations update normally.


## v1.14

- **The payload is gone. The file is readable.** `USB-Guard.bat` used to carry the program as
  a gzip + base64 blob that was written to `%TEMP%` and run from there. It now carries the
  PowerShell source in plain text: a short batch launcher, then the program itself.
  Open the file in Notepad and read every line of it. Nothing is decoded, nothing is written
  to a temporary folder, and `-ExecutionPolicy Bypass` is no longer used, because the script
  runs from memory rather than from disk.

- **The released file is the source.** `src/build.ps1` joins `src/header.bat` and
  `src/usb-guard.ps1` into `USB-Guard.bat` and checks that the two halves match. The release
  notes carry the SHA256 of the file.

- **The update check verifies what it downloads.** It compares the SHA256 of the downloaded
  file against the hash published in the release notes, refuses redirects that leave
  `github.com` / `githubusercontent.com`, and keeps the previous version under
  `C:\ProgramData\Usb-Guard\backup` before replacing itself. A file that fails any of these
  checks is deleted and reported as "new version available" instead of being installed.

- The watcher and the background scan start from the same single file; no `usb-guard.ps1` is
  left in `%TEMP%` or in the install folder any more, and an old one is deleted on first run.


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

- **Fewer false alarms in the PC scan.** A service whose binary sits under a temporary folder
  is no longer reported when that binary carries a valid Authenticode signature. CPU-Z, which
  drops a signed driver into `C:\Windows\Temp` while it runs, was being listed as a worm
  remnant.

- Scan wording: "1 suspicious remnant found", not "1 suspicious remnants found". A service
  finding no longer ends with a dangling `|` when it has no `ServiceDll`.


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
