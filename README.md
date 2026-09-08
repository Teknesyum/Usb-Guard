<!-- lang -->

[<img src="assets/badge-lang.svg" alt="English selected, switch to Türkçe" width="124" height="44">](README.tr.md)


<div align="center">

# USB&nbsp;·&nbsp;GUARD

### Clean, Immunize, And Check The PC Behind The USB

One self-elevating `.bat`. No install. Pick a drive, it cleans and locks it.
Open the menu, it tells you whether this computer is infected.

</div>

The program's own menu is Turkish; every item has an F1 help line, and this README names the items as they appear on screen.

---


## What Happened To Your USB


Your files are gone. A single shortcut, named like the drive, sits in their place. Opening it
shows your files again, so you think nothing is wrong. That is the **shortcut worm**: it hid
your files in a folder, dropped a look-alike `.lnk` that runs a hidden script, and left a
payload so the next computer catches it too.

USB-Guard was written against the family that uses a hidden `sysvolume` folder, and it also
covers the older VBS and JS worms that spread the same way.


---


## What USB-Guard Does


### Clean The USB

- Stops any worm process that is currently holding the drive.

- Deletes malicious shortcuts. It reads both the target and the arguments, so shortcuts that
  launch `cmd`, `wscript`, or `mshta` are caught even when they are named like your files.

- Moves your real files back from the hidden folder, whether the worm used the drive label,
  `sysvolume\<label>`, `_`, a blank name, or a fake `recycle.bin`. A name clash at the root
  gets a ` (2)` suffix, so nothing is overwritten or lost.

- Moves the payload (hidden `.vbs` / `.js` / `.bat` / `.hta` / `.scr` files, folder-icon
  `.exe` mimics named after your hidden folders, and double-extension fakes such as
  `holiday.jpg.exe`) to quarantine under `%LOCALAPPDATA%\Usb-Guard`, then clears the
  System + Hidden attributes.

- Scans subfolders two levels deep, not only the root. Worms of the Jenxcus family drop a
  copy of the shortcut and the payload into every folder they find.

- Records where each quarantined item came from. **Karantinadan Geri Al** in the advanced
  menu lists past quarantine folders and moves their contents back where they were.


### Immunize The USB

- Occupies the names a worm needs (`autorun.inf`, `recycler`, `recycled`, `sysvolume`, and
  the drive label) with locked decoy folders.

- Each decoy holds a reserved-name subfolder (`con..`) that normal delete cannot remove.
  Works on **FAT32 / exFAT** as well as NTFS.

- On NTFS a Deny ACL for Everyone blocks write, create, and delete on the decoy. The owner
  can always undo it.

An already-immunized drive is shown as **Aşılı** and skipped.


### Check This PC

Every time the menu opens, USB-Guard scans the computer and prints **Bu PC : Temiz** or
**N Kalıntı - Temizlik Önerilir**. If something is found, **Bu PC'yi Temizle (Önerilen)** is
the first item in the menu.

What it looks at:

| Where | What counts as a remnant |
| --- | --- |
| Running processes | `wscript`, `cscript`, `mshta` launched from Temp or AppData; miner binaries |
| `Run` / `RunOnce`, Policies `Run`, Winlogon `Shell` / `Userinit` | Script interpreters, `.vbs` / `.js` / `.bat` payloads, hidden PowerShell |
| Per-user Winlogon `Shell`, `AppInit_DLLs`, IFEO `Debugger` | Replaced user shell, injected DLLs, hijacked Task Manager / Registry Editor / cmd |
| Startup folders (user and all users) | Scripts, and shortcuts pointing at scripts |
| Scheduled tasks | Same rules, Microsoft tasks excluded |
| Services | `ServiceDll` outside System32, hijacked `DcomLaunch`, paths in Temp or `Windows \` |
| System32 | `svcinsty64.exe`, `svctrl64.exe`, `u######.dll`, `wsvcz\`, the fake `C:\Windows \System32` |
| Temp, AppData, ProgramData, user profile | Small script files that touch drives, shortcuts, or autorun |
| Windows Defender | Exclusions pointing at Temp, AppData, or the fake folder |
| Explorer sabotage | Task Manager, Registry Editor, Folder Options, or "show hidden files" disabled |

Everything found is listed first. Nothing changes until you answer **E / H** (Yes / No).
On confirmation: processes are stopped, services and autostart entries removed, Explorer
settings restored, and files **moved to quarantine** under `%LOCALAPPDATA%\Usb-Guard`, never
deleted. A file that is locked by Windows is moved on the next reboot.


---


### USB Execute Switch

**USB'den Çalıştırmayı Kapat** writes one Windows policy value, `Removable Disks: Deny
execute access`, so no `.exe` runs from any removable drive. A folder-icon fake cannot start
even if it is clicked. Installers and portable programs on a USB stop working too, so it is
optional and reversible from the same menu; sign out and back in for full effect.


### Script Engine Switch

Every VBS / JS worm runs through `wscript.exe`. **Betik Motorunu Kapat** turns Windows
Script Host off with one registry value, so a clicked shortcut launches nothing even on an
unprotected PC. The status row shows **Betik Motoru : Açık / Kapalı**. Legitimate `.vbs`
scripts (some printer installers, corporate logon scripts) stop too, so it is optional and
can be switched back on from the same menu.


## Optional Background Watcher


Install it from the menu. When an infected USB is plugged in, a Yes / No prompt asks whether
to clean and immunize it. Nothing runs without your click. Uninstall from the same menu.


---


## Usage


1. Download **`USB-Guard.bat`**.

2. Double-click it. Windows asks for admin, which the ACL locks and the PC cleanup need.

3. Arrow keys to move, **Enter** to select, **F1** to read what the highlighted item does,
   **G** to open GitHub, **Esc** to leave.

The first screen holds only cleaning and the PC scan. The watcher, the script-engine
switch, the USB execute switch, restore from quarantine, and the copy actions live under
**Gelişmiş Seçenekler**.

On launch USB-Guard compares its version with the latest GitHub release. A newer release is
downloaded, swapped in place of the running `.bat`, and the program restarts. The version
check, the PC scan, and the antivirus query run in the background: the menu is ready in
about a second and the status rows fill in as their answers arrive.

Removable USB drives and USB hard disks are listed. The system drive, cloud, and boot / EFI
partitions are hidden on purpose.

It is a plain `.bat`, so **cmd** runs it. Inside, it uses the **Windows PowerShell 5.1** that
ships with every Windows 7 and later. No PowerShell 7, no changed default shell.


---


## Safety


- **No self-propagation.** It touches only the drive you choose or approve.

- **Reversible.** Immunity is a set of folders and ACLs the owner can remove. The PC cleanup
  quarantines instead of deleting.

- **Local.** Its only network call is the version check against GitHub on launch; no data
  leaves the computer.

- **Not an antivirus.** It knows the USB worm families and their leftovers. Keep a real
  antivirus for everything else.


---


## License


AGPL-3.0-or-later. See [LICENSE](LICENSE).


<!-- signature -->
<div align="center">

<a href="https://github.com/sponsors/Teknesyum"><img src="assets/badge-sponsor.svg" alt="Support Teknesyum" height="38"></a>
&nbsp;
<a href="LICENSE"><img src="assets/badge-license.svg" alt="License AGPL-3.0" height="38"></a>

<br><br>

**Teknesyum** · [github.com/Teknesyum](https://github.com/Teknesyum)

</div>
