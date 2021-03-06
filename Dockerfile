FROM ubuntu:18.04
ARG BUILDROOT_VERSION=2018.02.1
ARG BASE_DEFCONFIG
LABEL maintainer="tudor@tudorholton.com"
RUN \
# Check for mandatory build arguments
    : "${BASE_DEFCONFIG:?Build argument needs to be set and non-empty.}" \
 && apt-get -y update && apt-get -y install locales build-essential wget git file cpio unzip zip python rsync bc libffi-dev openjdk-11-jdk \
 && mkdir /buildroot
# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8
WORKDIR /buildroot
RUN wget https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.bz2 \
 && tar xjvf buildroot-${BUILDROOT_VERSION}.tar.bz2 --strip-components=1 \
 && rm buildroot-${BUILDROOT_VERSION}.tar.bz2
#COPY openjdk /buildroot/package/openjdk
RUN cd package \
 && git clone https://github.com/h6w/buildroot-openjdk.git openjdk \
 && cd - \
 && patch -p0 < package/openjdk/brpatch/buildroot-menu.patch
RUN echo "BR2_TOOLCHAIN_BUILDROOT_LOCALE=y" >> /buildroot/configs/${BASE_DEFCONFIG}_defconfig
RUN echo "BR2_TOOLCHAIN_BUILDROOT_CXX=y" >> /buildroot/configs/${BASE_DEFCONFIG}_defconfig
RUN echo "BR2_PACKAGE_XORG7=y" >> /buildroot/configs/${BASE_DEFCONFIG}_defconfig
RUN echo "BR2_PACKAGE_XSERVER_XORG_SERVER=y" >> /buildroot/configs/${BASE_DEFCONFIG}_defconfig
RUN echo "BR2_PACKAGE_XTERM=y" >> /buildroot/configs/${BASE_DEFCONFIG}_defconfig
RUN echo "BR2_TARGET_ROOTFS_EXT2_SIZE=\"500M\"" >> /buildroot/configs/${BASE_DEFCONFIG}_defconfig
RUN echo "BR2_PACKAGE_OPENJDK=y" >> /buildroot/configs/${BASE_DEFCONFIG}_defconfig
RUN make ${BASE_DEFCONFIG}_defconfig
RUN make oldconfig
RUN make V=0 source
