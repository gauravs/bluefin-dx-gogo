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
