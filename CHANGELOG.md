# Changelog


## v1.6

- Bigger interface: the console is switched to Consolas 20 on open, the window grows to
  62×40 and stays centered.

- A blank line between every menu item, status row and step so the screen reads easily.

- Shorter menu labels: **Tumunu Duzelt**, **Duzelt -> D: LABEL**, **Izleyici Kur / Kaldir**,
  **USB-Guardı Usb'ye Kopyala**, **USB-Guardı C:'ye Kopyala**.


## v1.5

- The menu now scans the PC on open and shows **Bu PC : Temiz** or **N Kalıntı - Temizlik
  Önerilir**; when remnants exist, **Bu PC'yi Temizle (Önerilen)** becomes the first menu item.

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

- Status list marks a plugged-in USB as **Solucan İzi** when it carries shortcuts or a live
  `sysvolume`.

- Spinner no longer types character by character; each step is ~120 ms faster.

- README rewritten in both languages with a table of what the PC scan looks at.


## v1.4

- New menu option **Bu PC'yi Tara ve Kalıntıları Temizle**: scans `Run` / `RunOnce`, the
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
