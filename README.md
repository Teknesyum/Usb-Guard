# USB-Guard

Clean and immunize USB flash drives against shortcut / autorun worms — the family that hides your files, replaces them with a look-alike `.lnk` shortcut, and drops a hidden payload so the infection jumps to the next machine.

One self-elevating `.bat`. No install required. Pick a drive, it fixes and locks it.

## What It Does

**Clean**
- Removes malicious `.lnk` shortcuts that point at a hidden script.
- Restores the real files the worm hid inside a folder named after the drive label.
- Clears the hidden payload (`sysvolume` and similar drops).
- Un-hides files the worm marked System + Hidden.

**Immunize**
- Occupies the names a worm needs (`autorun.inf`, `recycler`, `recycled`, `sysvolume`, and the drive label) with locked decoy folders, so the worm cannot recreate them.
- Each decoy holds a reserved-name subfolder (`con..`) that normal delete operations cannot remove — this also works on FAT32/exFAT.
- On NTFS it additionally applies a Deny ACL for Everyone, blocking write/create/delete on the decoy.

Already-immunized drives are detected and shown as **Zaten Aşılı** (already immunized); they are skipped.

## Optional Background Watcher

You can install a lightweight watcher (opt-in, from the menu). When an infected USB is plugged in, it asks — with a Yes/No prompt — whether to clean and immunize it. Nothing runs without your click. Uninstall from the same menu at any time.

## Usage

1. Download `USB-Guard.bat`.
2. Double-click it. Windows asks for admin (needed for ACL locks) — approve.
3. Use the arrow keys to pick a drive, press Enter.

Only removable USB drives that are safe to immunize are listed. System, cloud, and boot/EFI partitions are hidden on purpose.

## Safety

- No self-propagation. It only touches the drive you choose, or one you approve at the prompt.
- Reversible: immunity is a set of folders and ACLs; the owner can always remove them.
- Runs locally. It talks to no network.

## License

MIT — see [LICENSE](LICENSE).

---

**Teknesyum** · [GitHub](https://github.com/Teknesyum) · [Sponsor](https://github.com/sponsors/Teknesyum)
