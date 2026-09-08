<!-- lang -->

[<img src="assets/badge-lang.svg" alt="English selected, switch to Türkçe" width="124" height="44">](README.tr.md)


<div align="center">

# USB&nbsp;·&nbsp;GUARD

### Clean, Immunize, And Check The PC Behind The USB

One self-elevating `.bat`. No install. Pick a drive, it cleans and locks it.
Open the menu, it tells you whether this computer is infected.

</div>

On the first run the program asks for a language: **1** for English, **2** for Turkish. The
choice is saved and not asked again; it can be changed from the advanced submenu at any
time. Every menu item carries a help page on the right arrow key, in the chosen language.

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

- Moves the payload (hidden `.vbs` / `.js` / `.bat` / `.hta` / `.scr` / `.url` / `.scf`
  files, folder-icon `.exe` mimics named after your hidden folders, and double-extension
  fakes such as `holiday.jpg.exe`) to quarantine under `C:\ProgramData\Usb-Guard`, then
  clears the System + Hidden attributes.

- **Reads the first 4 KB of a hidden file instead of trusting its extension.** A hidden
  `invoice.pdf` that starts with `MZ`, or a `notes.txt` that is really encoded VBScript
  (`#@~^`), is treated as a payload. This also stops USB-Guard from carrying such a file
  back out of the hidden folder and dropping it on your desktop.

- **Follows the arguments of a malicious shortcut.** The files a bad `.lnk` actually names
  are resolved on the same drive: a payload goes to quarantine, your real document simply
  loses its System + Hidden attributes and stays where it is.

- **Recognises the folder disguised as a system object.** A hidden folder carrying a
  `desktop.ini` with the Recycle Bin, This PC, Control Panel or "God Mode" CLSID, or a name
  ending in `.{GUID}`, is opened up like any other worm container — alongside `RECYCLER`,
  `RECYCLED`, `$RECYCLE.BIN.`, `_`, a blank name and the drive label.

- **Checks inside `System Volume Information` and `$RECYCLE.BIN`.** Those two folders are
  never deleted, but any file in them that is neither a genuine recycle-bin entry nor a
  known Windows file, and that looks executable, is quarantined. Raspberry Robin and PlugX
  both hide there.

- **Catches right-to-left override names.** `resim‮gpj.exe` renders as `resim exe.jpg` in
  Explorer; USB-Guard reads the real name.

- Scans subfolders three levels deep, not only the root, up to 20 000 files. Worms of the
  Jenxcus family drop a copy of the shortcut and the payload into every folder they find.

- Records where each quarantined item came from. **Restore From Quarantine**, in the advanced
  menu, lists past quarantine folders and moves their contents back where they were.


### Immunize The USB

- Occupies the names a worm needs (`autorun.inf`, `recycler`, `recycled`, `sysvolume`, and
  the drive label) with locked decoy folders.

- Each decoy holds a reserved-name subfolder (`con..`) that normal delete cannot remove.
  Works on **FAT32 / exFAT** as well as NTFS.

- On NTFS a Deny ACL for Everyone blocks write, create, and delete on the decoy. The owner
  can always undo it.

A drive whose decoys are all in place is marked **Guarded** and skipped. If only some of
them are — a new decoy name was added in a later version, or one was removed — it reads
**Partially Guarded**, and immunizing again fills in what is missing. A drive with none
reads **Not Guarded**.


### Check This PC

Every time the menu opens, USB-Guard scans the computer. The status block then reads either
clean or **N remnants, cleanup recommended**. When something is found, cleaning this PC
becomes the first item in the menu.

What it looks at:

| Where | What counts as a remnant |
| --- | --- |
| Running processes | `wscript`, `cscript`, `mshta` launched from Temp or AppData; miner binaries |
| `Run` / `RunOnce`, Policies `Run`, Winlogon `Shell` / `Userinit` | Script interpreters, `.vbs` / `.js` / `.bat` payloads, hidden PowerShell |
| Per-user Winlogon `Shell`, `AppInit_DLLs`, IFEO `Debugger` | Replaced user shell, injected DLLs, hijacked Task Manager / Registry Editor / cmd |
| `UserInitMprLogonScript`, `User Shell Folders\Startup` | Logon script, and a Startup folder redirected somewhere else |
| Startup folders (user and all users) | Scripts, and shortcuts pointing at scripts |
| Scheduled tasks | Same rules, Microsoft tasks excluded |
| Services | `ServiceDll` outside System32, hijacked `DcomLaunch`, paths in Temp or `Windows \` |
| Signed programs in user-writable folders | An unsigned DLL sitting next to them — the sideloading trick Mustang Panda uses to run PlugX |
| System32 | `svcinsty64.exe`, `svctrl64.exe`, `u######.dll`, `wsvcz\`, the fake `C:\Windows \System32` |
| Temp, AppData, ProgramData, user profile, `Public\Documents`, `Users\Default` | Small script files that touch drives, shortcuts, or autorun — two subfolder levels deep |
| Windows Defender | Path, extension and process exclusions pointing at Temp, AppData, ProgramData or `Users\Public`, in both the normal and the policy branch |
| Explorer sabotage | Task Manager, Registry Editor, Folder Options, or "show hidden files" disabled |

Everything found is listed first. Nothing changes until you answer the yes / no prompt.
On confirmation: processes are stopped, services and autostart entries removed, Explorer
settings restored, and files **moved to quarantine** under `C:\ProgramData\Usb-Guard`, never
deleted. A file that is locked by Windows is moved on the next reboot.


---


### USB Execute Switch

This switch writes one Windows policy value, `Removable Disks: Deny execute access`, so no
`.exe` runs from any removable drive. A folder-icon fake cannot start
even if it is clicked. Installers and portable programs on a USB stop working too, so it is
optional and reversible from the same menu; sign out and back in for full effect.


### Script Engine Switch

Every VBS / JS worm runs through `wscript.exe`. This switch turns Windows Script Host off
with one registry value, so a clicked shortcut launches nothing even on an unprotected PC.
The status block reports whether the engine is on or off. Legitimate `.vbs`
scripts (some printer installers, corporate logon scripts) stop too, so it is optional and
can be switched back on from the same menu.


## Optional Background Watcher


Install it from the menu. It is registered as a scheduled task named `UsbGuard` with a logon
trigger for the built-in Users group, so it covers every account on the computer, and it runs
without administrator rights. When an infected USB is plugged in, a Yes / No prompt asks
whether to clean and immunize it. Nothing runs without your click. Uninstall from the same
menu.


---


## Usage


1. Download **`USB-Guard.bat`**.

2. Double-click it. Windows asks for admin, which the ACL locks and the PC cleanup need.

3. On the first run, press **1** for English or **2** for Turkish. The choice is remembered.

4. Arrow keys to move, **Enter** to select, **right arrow** to read what the highlighted
   item does, **left arrow** to go back, **G** to open GitHub, **Esc** to leave.

The first screen holds cleaning, the PC scan, and the two install actions. Installing to a
USB names the drive it will write to, so several plugged-in sticks are not a guess. The
watcher, the script-engine switch, the USB execute switch, restore from quarantine, and the
language switch live under the advanced submenu.

After a drive is cleaned, USB-Guard offers to copy itself onto that drive, so you can carry
it to the next infected computer.

The PC scan numbers what it finds. If something on the list is yours and you want to keep it,
type its number at the prompt instead of confirming: it is written to an ignore list and is
not reported again. **Clear The Ignore List** in the advanced menu brings them all back.

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

- **Readable.** `USB-Guard.bat` is a plain text file. Right-click it, choose Edit, and you
  see the whole program: a short batch launcher and then the PowerShell source, exactly as it
  is in `src/usb-guard.ps1`. Nothing is compressed, encoded, or unpacked into a temporary
  folder before it runs.

- **Verifiable.** Every release note carries the SHA256 of the file. Compare it with
  `Get-FileHash .\USB-Guard.bat -Algorithm SHA256` before you run it.

- **Scanned.** The v1.15 release asset was uploaded to VirusTotal and came back clean, no
  vendor flags:
  [report for 2d5c45b6…f368](https://www.virustotal.com/gui/file/2d5c45b642671c465f9d2cea945b693e61003b5fa2f5054a60491c7a9374f368).
  The hash in that link is the hash of that asset. Later versions are not uploaded
  automatically — the file is plain text and you can read it yourself.

- **Documented.** [SECURITY.md](SECURITY.md) lists every privileged action the program
  takes, why it takes it, and how to undo it.

- **Not an antivirus.** It knows the USB worm families and their leftovers. Keep a real
  antivirus for everything else.


---


## What It Does Not Do

Worth knowing before you rely on it.

- **BadUSB / HID.** A device that presents itself as a keyboard and types commands is not a
  file, so there is nothing on the drive to find. Only Windows device policy stops that.

- **File infectors.** Sality and Ramnit write themselves into your existing `.exe` files.
  Removing the infection means repairing each host file; USB-Guard does not attempt it, and
  a real antivirus should.

- **ISO, IMG and VHD images.** Windows mounts them as a drive of their own. USB-Guard does
  not open container files, so a payload inside one is invisible to it.

- **Firmware and bootkits.** Nothing below the file system is in scope.

A handful of file and process names in the code (`xmrig`, `svctrl64`, `svcinsty64`,
`wsvcz`) are signatures of specific campaigns rather than general rules. They cost nothing
and catch a common case; they are not what the tool relies on.


---


## Building It Yourself


The program is `src/usb-guard.ps1`, plain PowerShell. `src/build.ps1` puts the batch launcher
`src/header.bat` in front of it and writes `USB-Guard.bat`, then verifies that the body of the
built file is byte for byte the source it started from and prints the SHA256.


```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\src\build.ps1
```


The same file is both a Windows batch file and a PowerShell script: `cmd.exe` reads the first
lines and stops at `exit /b`, PowerShell reads them as a comment block and runs what follows.


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
