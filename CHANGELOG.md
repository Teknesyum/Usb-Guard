# Changelog


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
