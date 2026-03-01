ARG BASE_IMAGE="ghcr.io/ublue-os/bluefin-dx:stable"

FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /system_files

FROM ${BASE_IMAGE}

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    bash /ctx/build_files/build.sh

RUN bootc container lint
