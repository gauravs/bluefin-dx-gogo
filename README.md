# bluefin-dx-gogo

Custom immutable Linux image based on [Bluefin DX](https://projectbluefin.io/) with [Niri](https://github.com/YaLTeR/niri) compositor and [DankMaterialShell](https://gitlab.com/anthroplankton/dms).

Two variants:
- **bluefin-dx-gogo** — Intel-only (laptop)
- **bluefin-dx-gogo-nvidia** — Nvidia RTX 4090 (desktop)

Built daily via GitHub Actions and published to GHCR.

## Local Build

```bash
just build          # Intel variant
just build-nvidia   # Nvidia variant
just lint           # Run bootc container lint
just check          # Verify installed packages
```

## Rebase

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/<owner>/bluefin-dx-gogo:latest
```
