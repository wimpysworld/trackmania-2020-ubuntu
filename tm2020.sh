#!/usr/bin/env bash

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! Run this script as a regular user"
  exit 1
fi

TM_PATH="${HOME}/Games/TM2020"
mkdir -p "${TM_PATH}"/{Prefix,Proton}

# Install Wine GE Proton requirements for Ubuntu and derivatives
if command -v lsb_release 1>/dev/null; then
  OS_ID=$(lsb_release --id --short)
  case "${OS_ID}" in
    Elementary|Linuxmint|Neon|Pop|Ubuntu)
      if ! dpkg -s winehq-staging 1>/dev/null; then
        echo "Installing winehq-staging"
        wget -nc https://dl.winehq.org/wine-builds/winehq.key -O "${TM_PATH}/winehq.key"
        sudo dpkg --add-architecture i386 && \
        sudo apt-key add "${TM_PATH}/winehq.key" && \
        sudo apt-add-repository -y --no-update 'https://dl.winehq.org/wine-builds/ubuntu/' && \
        sudo apt-get -y update && \
        sudo apt-get -y install --install-recommends winehq-staging && \
        sudo apt-get -y install winetricks
      fi
      ;;
    *) echo "WARNING! Unknown distro, you need to install winehq-staging manually.";;
  esac
else
  echo "WARNING! Unknown distro, you need to install winehq-staging manually."
fi

# Download UbisoftConnectInstaller.exe
echo "Downloading UbisoftConnectInstaller.exe"
if ! wget --quiet --continue --show-progress --progress=bar:force:noscroll "https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe" -O "${TM_PATH}/UbisoftConnectInstaller.exe"; then
  echo "ERROR! Failed to download UbisoftConnectInstaller.exe. Try running ${0} again."
  exit 1
fi

# Download Proton GE
PROTON_PATH=""
PROTON_VER="GE-Proton7-6"
echo "Downloading wine-lutris-${PROTON_VER}-x86_64.tar.xz"
if ! wget --quiet --continue --show-progress --progress=bar:force:noscroll "https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${PROTON_VER}/wine-lutris-${PROTON_VER}-x86_64.tar.xz" -O "${TM_PATH}/wine-lutris-${PROTON_VER}-x86_64.tar.xz"; then
  echo "ERROR! Failed to download wine-lutris-${PROTON_VER}-x86_64.tar.xz. Try running ${0} again."
  exit 1
fi

# Unpack Proton
if [ ! -d "${TM_PATH}/Proton/lutris-${PROTON_VER}-x86_64" ]; then
  echo "Unpacking wine-lutris-${PROTON_VER}-x86_64.tar.xz"
  tar -xf "${TM_PATH}/wine-lutris-${PROTON_VER}-x86_64.tar.xz" -C "${TM_PATH}/Proton/"
fi

PROTON_PATH="${TM_PATH}/Proton/lutris-${PROTON_VER}-x86_64/bin"

# Create wine prefix
if [ ! -e "${TM_PATH}/Prefix/drive_c/windows/win.ini" ]; then
  echo "Creating Prefix: ${TM_PATH}/Prefix"
  env WINEDEBUG=-all WINEPREFIX="${TM_PATH}/Prefix" "${PROTON_PATH}/wine" wineboot --init >/dev/null 2>&1
fi

# Install Ubisoft Connect
if [ ! -e "${TM_PATH}/Prefix/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/UbisoftConnect.exe" ]; then
  echo "Installing UbisoftConnectInstaller.exe"
  env WINEDEBUG=-all WINEPREFIX="${TM_PATH}/Prefix" "${PROTON_PATH}/wine" "${TM_PATH}/UbisoftConnectInstaller.exe" /S >/dev/null 2>&1
fi

# Tweak Ubisoft Game Launcher
if [ ! -e "${TM_PATH}/Prefix/drive_c/users/steamuser/Local Settings/Application Data/Ubisoft Game Launcher/settings.yml" ]; then
  mkdir -p "${TM_PATH}/Prefix/drive_c/users/steamuser/Local Settings/Application Data/Ubisoft Game Launcher"
  echo 'overlay:
  enabled: false
  user:
    closebehavior: CloseBehavior_Minimize' > "${TM_PATH}/Prefix/drive_c/users/steamuser/Local Settings/Application Data/Ubisoft Game Launcher/settings.yml"
fi

# Launch Track Mania 2020
if [ -e "${TM_PATH}/Prefix/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/games/Trackmania/Trackmania.exe" ]; then
  env WINEDEBUG=-all WINEPREFIX="${TM_PATH}/Prefix" WINEDLLOVERRIDES="winemenubuilder.exe=d" "${PROTON_PATH}/wine" "${TM_PATH}/Prefix/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/games/Trackmania/Trackmania.exe"
else
  env WINEDEBUG=-all WINEPREFIX="${TM_PATH}/Prefix" WINEDLLOVERRIDES="winemenubuilder.exe=d" "${PROTON_PATH}/wine" "${TM_PATH}/Prefix/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/UbisoftConnect.exe" "uplay://launch/5595/0"
fi
