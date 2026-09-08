<!-- lang -->

[<img src="assets/badge-lang.svg" alt="English selected, switch to Türkçe" width="124" height="44">](README.tr.md)


<div align="center">

# USB&nbsp;·&nbsp;GUARD

### Fix And Immunize USB Drives Against Shortcut Worms

One self-elevating `.bat`. No install. Pick a drive — it cleans it and locks it.

</div>


---


## The Problem


You plug in your USB and your files are gone. In their place sits a single shortcut, or a
folder that opens something you never clicked. This is the **shortcut / autorun worm** — the
one that spreads across a whole computer lab, one flash drive at a time.

It does three things: it **hides** your real files, drops a **look-alike shortcut** that runs
a hidden script, and leaves a **payload** behind so the next machine catches it too.


---


## What USB-Guard Does


### Clean

- Removes the malicious `.lnk` shortcuts that point at a hidden script.

- Moves back the real files the worm hid inside a folder named after the drive label.

- Deletes the payload (`sysvolume` and similar).

- Un-hides files the worm marked System + Hidden.


### Immunize

- Occupies the names a worm needs — `autorun.inf`, `recycler`, `recycled`, `sysvolume`, and
  the drive label — with locked decoy folders, so the worm cannot recreate them.

- Each decoy holds a subfolder with a reserved name (`con..`) that normal delete cannot
  remove. This works on **FAT32 / exFAT** too, not only NTFS.

- On NTFS it also applies a **Deny ACL** for Everyone, blocking write / create / delete on the
  decoy. The owner can always undo it.


A drive that is already protected is detected, shown as **Zaten Aşılı** (already immunized),
and skipped.


### Scan This PC

New in **v1.4**: the menu option **Bu PC'yi Tara ve Kalıntıları Temizle** (Scan This PC and
Clean Leftovers) looks for worm remnants on the computer itself:

- Windows autostart entries (`Run` / `RunOnce`).

- The Startup folder.

- Suspicious `.vbs` payloads in `Temp` and `AppData`.

Everything it finds is listed first. Nothing is touched until you confirm with **E / H**
(Yes / No). On confirmation, autostart entries are deleted and files are **moved to
quarantine**, not deleted — you can restore them.


---


## Optional Background Watcher


You can install a lightweight watcher — opt-in, from the menu. When an infected USB is plugged
in, it asks with a Yes / No prompt whether to clean and immunize it.

Nothing runs without your click. Uninstall from the same menu at any time.


---


## Usage


1. Download **`USB-Guard.bat`**.

2. Double-click it. Windows asks for admin — the ACL locks need it — approve.

3. Use the **arrow keys** to pick a drive or a menu option, then press **Enter**.


The drive list shows only removable USB drives. System, cloud, and boot / EFI partitions are
hidden on purpose.


### Works Everywhere

It is a plain `.bat` — **cmd** runs it. Inside, it calls the **built-in Windows PowerShell
5.1**, which ships with every Windows 7 and later. It does **not** need PowerShell 7, and it
does **not** need PowerShell to be your default shell.


---


## Safety


- **No self-propagation.** It only touches the drive you choose, or one you approve at the
  prompt.

- **Reversible.** Immunity is a set of folders and ACLs the owner can remove; the PC scan
  quarantines files instead of deleting them.

- **Local.** It talks to no network.


---


## License


AGPL-3.0-or-later — see [LICENSE](LICENSE).


<!-- signature -->
<div align="center">

<a href="https://github.com/sponsors/Teknesyum"><img src="assets/badge-sponsor.svg" alt="Support Teknesyum" height="38"></a>
&nbsp;
<a href="LICENSE"><img src="assets/badge-license.svg" alt="License AGPL-3.0" height="38"></a>

<br><br>

**Teknesyum** · [github.com/Teknesyum](https://github.com/Teknesyum)

</div>
