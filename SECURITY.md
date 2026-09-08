# Security


## What This Program Is


`USB-Guard.bat` is a single plain text file. The first lines are a Windows batch launcher;
everything after them is the PowerShell source of the program, identical to
[src/usb-guard.ps1](src/usb-guard.ps1). Nothing is compressed, encoded, or written to a
temporary folder before it runs. Open the file in Notepad and read it.

Every release note carries the SHA256 of the published file:

```powershell
Get-FileHash .\USB-Guard.bat -Algorithm SHA256
```


## Why Windows Asks For Administrator Rights


Cleaning a USB stick, reading the machine's startup entries, and creating a scheduled task
all need elevation. The launcher asks for it once, at start.


## Every Privileged Thing It Does


| What | Why | Reversible | Where it lands |
| --- | --- | --- | --- |
| Creates locked folders on the USB root (`autorun.inf`, `sysvolume`, `recycler`, `recycled`, the drive label) with `Everyone: Deny Write` | The worm cannot create a file where a folder of that name already exists | Yes — delete the folders, or use **Remove Immunity** | The chosen USB drive |
| Deletes malicious `.lnk` files on the USB | They are the worm's launcher, not user data | No — they are recreated shortcuts, not files | The chosen USB drive |
| Moves `.vbs` / `.js` / `.exe` payloads off the USB | Removes the worm body | Yes — **Restore From Quarantine** | `C:\ProgramData\Usb-Guard\quarantine`, with a manifest of original paths |
| Reads Run / RunOnce, Winlogon, startup folders, scheduled tasks, services, Defender exclusions and Explorer policy values | Finds worm remnants on this PC | Reading only | Nothing is written |
| Deletes the registry entries you approve and quarantines their files | Cleanup, after an explicit Yes | Registry entries: no. Files: yes, from quarantine | `C:\ProgramData\Usb-Guard\quarantine` |
| Optional: disables Windows Script Host (`HKLM\Software\Microsoft\Windows Script Host\Settings\Enabled`) | `.vbs` / `.js` worms run through `wscript.exe` | Yes, from the same menu | Off by default |
| Optional: denies execute access on removable disks (Windows policy) | A folder-icon fake `.exe` cannot start | Yes, from the same menu | Off by default |
| Optional watcher: a scheduled task named `UsbGuard` for the built-in Users group | Asks Yes / No when an infected USB is plugged in | Yes — **Remove Watcher** | `C:\ProgramData\Usb-Guard\USB-Guard.bat` |
| Copies itself to `C:\USB-Guard.bat`, to `C:\ProgramData\Usb-Guard`, or to a USB you pick | Quick access, and carrying it to the next PC | Yes — delete the copy | Where you chose |
| One HTTPS request to `api.github.com` on launch | Version check | — | No data is sent; only the release tag is read |


## Updates


The update check compares the SHA256 of the downloaded file against the hash published in
the release notes. It refuses redirects that leave `github.com` / `githubusercontent.com`,
refuses a version lower than the one running, and keeps the previous version in
`C:\ProgramData\Usb-Guard\backup` before replacing itself. A file that fails any of these
checks is deleted, and the program only reports that a new version exists.


## What It Never Does


It does not copy itself to a drive you did not pick, does not permanently delete anything,
does not send any data anywhere, does not touch files outside the drive you chose and the
startup locations listed above, and does not stay resident unless you install the watcher.


## Reporting


Open an issue at https://github.com/Teknesyum/Usb-Guard/issues, or, for something you would
rather not post in public, use GitHub's private vulnerability reporting on the same
repository.
