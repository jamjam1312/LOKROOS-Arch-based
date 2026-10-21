# Standalone installation model

LOKRO OS does not require an existing Arch Linux installation. `mkarchiso` starts from Arch's official `releng` profile, resolves signed packages from the official Arch repositories plus the locally built LOKRO packages, and constructs a dedicated x86_64 root filesystem. That complete filesystem is stored as `arch/x86_64/airootfs.sfs` inside the hybrid ISO.

At installation time Calamares performs these stages:

1. create or select the target partitions;
2. mount the target filesystem;
3. unpack LOKRO's embedded root filesystem;
4. create the selected locale, keyboard, hostname and first local administrator;
5. apply optional desktop, graphics, application and gaming package choices;
6. remove live-session accounts, autologin, Archiso initramfs hooks, installer files and the temporary offline-media repository;
7. write the normal disk-root initramfs policy and generate initramfs, `/etc/fstab` and GRUB for the installed machine.

The installer discovers the embedded root below the active runtime mounts and
provides it to Calamares through `/run/lokro-installer/airootfs.sfs`. This
supports the traditional Archiso path as well as an already-mounted Ventoy
loop image without mounting or modifying another disk. Calamares keeps Ventoy
mounts in its `essentialMounts` allowlist while installing.

On the partition page no destructive option is preselected. **Replace** lets
the user explicitly choose one existing partition; after the summary is
confirmed, Calamares reformats that chosen partition as ext4 and installs LOKRO
there. **Erase**, **Alongside** and the manual editor remain available. This is
the real partitioning backend, not a simulated LOKRO dialog.

The source tree does not download or repackage the generic Arch release ISO. It builds a custom installable root from official packages. This distinction matters because copying the unmodified Arch live environment to a disk is not a supported installation method; LOKRO owns and validates the package manifest and cleanup step for its custom image.

The offline ISO carries all packages needed for the base desktop, office suite, optional NVIDIA path, gaming bundle and optional Hyprland session. The online ISO always carries a bootable Plasma base and downloads selected extras only when a network is available.

No repository validation or ISO build command writes firmware, boot entries or partitions on the developer's Windows computer. Destructive disk operations happen only inside Calamares after the user selects a target and confirms its final summary. VM tests must use disposable virtual disks.
