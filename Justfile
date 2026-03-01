default_base := "ghcr.io/ublue-os/bluefin-dx:stable"
nvidia_base := "ghcr.io/ublue-os/bluefin-dx-nvidia-open:stable"
engine := if `command -v podman 2>/dev/null || true` != "" { "podman" } else { "docker" }

# Build Intel variant
build:
    {{engine}} build -f Containerfile --network=host --build-arg BASE_IMAGE={{default_base}} -t bluefin-dx-gogo:latest .

# Build Nvidia variant
build-nvidia:
    {{engine}} build -f Containerfile --network=host --build-arg BASE_IMAGE={{nvidia_base}} -t bluefin-dx-gogo-nvidia:latest .

# Run bootc container lint on the image
lint:
    {{engine}} run --rm localhost/bluefin-dx-gogo:latest bootc container lint

# Check installed packages
check:
    {{engine}} run --rm localhost/bluefin-dx-gogo:latest rpm -q niri quickshell-git dms greetd

# Interactive shell into the image
shell:
    {{engine}} run --rm -it localhost/bluefin-dx-gogo:latest bash

# Create bootable qcow2 from container image (requires sudo for disk partitioning)
vm-disk:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p output
    raw="$PWD/output/bluefin-dx-gogo.raw"
    qcow="$PWD/output/bluefin-dx-gogo.qcow2"
    # Create raw disk and attach as loop device
    rm -f "$raw"
    truncate -s 20G "$raw"
    loopdev=$(sudo losetup --find --show --partscan "$raw")
    echo "Using loop device: $loopdev"
    # Copy image to root's podman storage (skip if already there)
    if ! sudo podman image exists localhost/bluefin-dx-gogo:latest 2>/dev/null; then
        podman image scp "$(id -un)@localhost::localhost/bluefin-dx-gogo:latest" root@localhost::
    fi
    # Install to the loop device
    sudo podman run --rm --privileged --pid=host --network=host \
        --security-opt label=type:unconfined_t \
        -e LANG=C.UTF-8 \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        localhost/bluefin-dx-gogo:latest \
        bootc install to-disk --generic-image --filesystem btrfs "$loopdev"
    sudo losetup -d "$loopdev"
    # Convert to qcow2
    qemu-img convert -f raw -O qcow2 "$raw" "$qcow"
    rm -f "$raw"
    echo "Created $qcow"

# Boot existing qcow2
vm-boot:
    qemu-system-x86_64 \
        -enable-kvm -m 8192 -smp 4 \
        -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
        -drive file=output/bluefin-dx-gogo.qcow2,format=qcow2,if=virtio \
        -nic user,model=virtio-net-pci \
        -display gtk

# Build image, create disk, and boot — one command
vm: build vm-disk vm-boot
