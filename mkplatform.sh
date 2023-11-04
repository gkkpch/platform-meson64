#!/bin/bash
set -eo pipefail

[[ $# -ge 1 ]] && shift 1
if [[ $# -ge 0 ]]; then
  armbian_extra_flags=("$@")
  echo "Passing additional args to Armbian ${armbian_extra_flags[*]}"
else
  armbian_extra_flags=("")
fi

C=$(pwd)
A=../armbian
P="meson64"
B="current"
K="meson64"
F="23.02.2"


DELAY=2 # Number of seconds to display results
while true; do
  clear
  cat << _EOF_
Please select the Amlogic Meson64 board you wish to build the platform files for:
1. Odroid C4
2. Odroid N2
3. Radxa Zero
4. Radxa Zero2
5. Quit

_EOF_

  read -p "Enter selection [1-5] > "
  if [[ $REPLY =~ ^[1-5]$ ]]; then
    case $REPLY in
      1)
        T="odroidc4"
        break
        ;; 
      2)
        T="odroidn2"
        break
        ;; 
      3)
        T="radxa-zero"
        break
        ;; 
      4)
        T="radxa-zero2"
        break
        ;;
      5)
        echo "Platform build interrupted"
        exit
        ;;
    esac
  else
    echo "Invalid entry, please select either 1-4 or quit with 5"
    sleep $DELAY
  fi
done

DELAY=0

while true; do
  read -p "Patch the kernel? [y/n]  > "
  if [[ $REPLY =~ ^[yn]$ ]]; then
    case $REPLY in
      y)
        PATCH="yes"
        break
        ;; 
      n)
        PATCH="no"
        break
        ;; 

    esac
  else
    echo "Invalid entry, please select either y or n"
    sleep $DELAY
  fi
done

while true; do
  read -p "Configure the kernel? [y/n]  > "
  if [[ $REPLY =~ ^[yn]$ ]]; then
    case $REPLY in
      y)
        CONFIGURE="yes"
        break
        ;; 
      n)
        CONFIGURE="no"
        break
        ;; 

    esac
  else
    echo "Invalid entry, please select either y or n"
    sleep $DELAY
  fi
done

# Make sure we grab the right version
ARMBIAN_VERSION=$(cat ${A}/VERSION)
export INSTALL_MOD_STRIP=1

# Custom patches
echo "Adding custom patches"

mkdir -p "${A}"/userpatches/kernel/"${K}"-"${B}"/
rm -rf "${A}"/userpatches/kernel/"${K}"-"${B}"/*.patch
FILES="${C}"/patches/*.patch
shopt -s nullglob
for file in $FILES; do
  cp $file "${A}"/userpatches/kernel/"${K}"-"${B}"/
done

# Custom kernel Config
if [ -e "${C}"/kernel-config/linux-"${K}"-"${B}".config ]
then
  echo "Copy custom Kernel config"
  rm -rf  "${A}"/userpatches/linux-"${K}"-"${B}".config
  cp "${C}"/kernel-config/linux-"${K}"-"${B}".config "${A}"/userpatches/
fi

# Select specific Kernel and/or U-Boot version
rm -rf "${A}"/userpatches/lib.config
if [ -e "${C}"/kernel-ver/"${P}".config ]
then
  echo "Copy specific kernel/uboot version config"
  cp "${C}"/kernel-ver/"${P}"*.config "${A}"/userpatches/lib.config
fi

cd ${A}
ARMBIAN_HASH=$(git rev-parse --short HEAD)
echo "Building for $T -- with Armbian ${ARMBIAN_VERSION} -- $B"

./compile.sh ARTIFACT_IGNORE_CACHE=yes BOARD=${T} BRANCH=${B} uboot 

if [ $PATCH == yes ]; then
  ./compile.sh ARTIFACT_IGNORE_CACHE=yes BOARD=${T} BRANCH=${B} kernel-patch 
fi
if [ $CONFIGURE == yes ]; then
  ./compile.sh ARTIFACT_IGNORE_CACHE=yes BOARD=${T} BRANCH=${B} kernel-configure 
fi

./compile.sh REPOSITORY_INSTALL=armbian-firmware CLEAN_LEVEL=images,debs,make-kernel ARTIFACT_IGNORE_CACHE=yes BOARD=${T} BRANCH=${B} kernel

echo "Done!"

cd "${C}"

# temporary rename odroidc4/n2 to c4a and n2a until meson64 move completed
U=${T}
if [ "${T}" == "odroidc4" ]; then
   T="odroidc4a"
fi
if [ "${T}" == "odroidn2" ]; then
   T="odroidn2a"
fi

echo "Creating platform ${T} files"
[[ -d ${T} ]] && rm -rf "${T}"
mkdir -p "${T}"/u-boot
mkdir -p "${T}"/lib/firmware
mkdir -p "${T}"/boot/overlay-user
mkdir -p "${T}"/var/lib/alsa
mkdir -p "${T}"/var/lib/alsa
mkdir -p "${T}"/volumio/app/plugins/audio_interface/alsa_controller

# Copy asound.state
cp "${C}/audio-routing/${T}-asound.state" "${T}"/var/lib/alsa/asound.state

# Copy radxa card profiles
cp "${C}/audio-routing/cards.json" "${T}"/volumio/app/plugins/audio_interface/alsa_controller

# Keep a copy for later just in case

#cp "${A}/output/debs/linux-headers-${B}-${K}_${ARMBIAN_VERSION}"* "${C}"

echo "${A}/output/debs/linux-dtb-${B}-${K}_${ARMBIAN_VERSION}"*.deb
dpkg-deb -x "${A}/output/debs/linux-dtb-${B}-${K}_${ARMBIAN_VERSION}"*.deb "${T}"
echo "${A}/output/debs/linux-image-${B}-${K}_${ARMBIAN_VERSION}"*.deb
dpkg-deb -x "${A}/output/debs/linux-image-${B}-${K}_${ARMBIAN_VERSION}"*.deb "${T}"
echo "${A}/output/debs/linux-u-boot-${U}-${B}_${ARMBIAN_VERSION}"*.deb
dpkg-deb -x "${A}/output/debs/linux-u-boot-${U}-${B}_${ARMBIAN_VERSION}"*.deb "${T}"
#echo "${A}/output/debs/armbian-firmware_${ARMBIAN_VERSION}"*.deb
#dpkg-deb -x "${A}/output/debs/armbian-firmware_${ARMBIAN_VERSION}"*.deb "${T}"

# The stepped "compile.sh" approach does not produce an armbian firmware .deb package
# Just copy it straight from the Armbian APT repo 
# (https://armbian.systemonachip.net/apt/pool/main/a/armbian-firmware/)

echo "Using a current Firmware (armbian-firmware_${F}_all.deb)"
wget -O "${C}"/firmware/armbian-firmware_${F}_all.deb https://armbian.systemonachip.net/apt/pool/main/a/armbian-firmware/armbian-firmware_${F}_all.deb 
dpkg-deb -x "${C}"/firmware/armbian-firmware_${F}_all.deb "${T}"
rm "${C}"/firmware/armbian-firmware_${F}_all.deb

cp "${T}"/usr/lib/linux-u-boot-${B}-${U}*/u-boot.bin "${T}/u-boot/"
cp "${T}"/usr/lib/u-boot/platform_install.sh "${T}/u-boot/"

mv "${T}"/boot/dtb* "${T}"/boot/dtb
mv "${T}"/boot/vmlinuz* "${T}"/boot/Image

# Copy any additional firmware
cp -r "${C}"/firmware "${T}"/lib

# Clean up unneeded parts
rm -rf "${T}/lib/firmware/.git"
rm -rf "${T:?}/usr" "${T:?}/etc"

# Compile and copy over overlay(s) files
for dts in "${C}"/overlay-user/overlays-"${T}"/*.dts; do
  dts_file=${dts%%.*}
  if [ -s "${dts_file}.dts" ]
  then
    echo "Compiling ${dts_file}"
    dtc -O dtb -o "${dts_file}.dtbo" "${dts_file}.dts"
    cp "${dts_file}.dtbo" "${T}"/boot/overlay-user
  fi
done

# Copy and compile boot script
if [ -f "${C}/bootparams/boot-${T}.cmd" ]; then
  cp "${C}/bootparams/boot-${T}.cmd" "${T}"/boot/boot.cmd
else
  cp "${A}"/config/bootscripts/boot-"${K}".cmd "${T}"/boot/boot.cmd
fi
mkimage -C none -A arm -T script -d "${T}"/boot/boot.cmd "${T}"/boot/boot.scr

# Copy userEnv.txt template
if [ -f "${C}/bootparams/userEnv-${T}.template" ]; then
 cp "${C}/bootparams/userEnv-${T}.template" "${T}"/boot/userEnv.template
fi

# Signal mainline kernel
touch "${T}"/boot/.next

# Prepare boot parameters
cp "${C}"/bootparams/"armbianEnv-${T}".txt "${T}"/boot/armbianEnv.txt

echo "Creating device tarball.."
tar cJf "${T}_${B}.tar.xz" "$T"

echo "Renaming tarball for Build scripts to pick things up"
mv "${T}_${B}.tar.xz" "${T}.tar.xz"
KERNEL_VERSION="$(basename ./"${T}"/boot/config-*)"
KERNEL_VERSION=${KERNEL_VERSION#*-}
echo "Creating a version file Kernel: ${KERNEL_VERSION}"
cat <<EOF >"${C}/version"
BUILD_DATE=$(date +"%m-%d-%Y")
ARMBIAN_VERSION=${ARMBIAN_VERSION}
ARMBIAN_HASH=${ARMBIAN_HASH}
KERNEL_VERSION=${KERNEL_VERSION}
EOF

echo "Cleaning up.."
rm -rf "${T}"
