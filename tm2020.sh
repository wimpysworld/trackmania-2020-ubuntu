#!/usr/bin/env bash

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! Run this script as a regular user"
  exit 1
fi

# Install Proton GE requirements for Ubuntu and derivatives
if command -v lsb_release 1>/dev/null; then
  OS_ID=$(lsb_release --id --short)
  case "${OS_ID}" in
    Elementary|Linuxmint|Neon|Pop|Ubuntu)
      # Install dependancies
      for PACKAGE in libudev0 winbind wine32; do
        if ! dpkg -s ${PACKAGE} 1>/dev/null; then
          echo "Installing ${PACKAGE}:"
          sudo apt-get -y install ${PACKAGE}
        else
          echo "${PACKAGE} is already iinstalled. This is good."
        fi
      done
      ;;
    *) echo "WARNING! Unknown distro, you might need to install 'libudev0' and 'winbind' manually.";;
  esac
else
  echo "WARNING! Unknown distro, you might need to install 'libudev0' and 'winbind' manually."
fi

TM_PATH="${HOME}/Games/TM2020"
mkdir -p "${TM_PATH}"/{Prefix,Proton}

# Download UbisoftConnectInstaller.exe
echo "Downloading UbisoftConnectInstaller.exe"
if ! wget --quiet --continue --show-progress --progress=bar:force:noscroll "https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe" -O "${TM_PATH}/UbisoftConnectInstaller.exe"; then
  echo "ERROR! Failed to download UbisoftConnectInstaller.exe. Try running ${0} again."
  exit 1
fi

# Download Proton GE
PROTON_PATH=""
PROTON_VER="7.3-GE-1"
echo "Downloading Proton-${PROTON_VER}.tar.gz"
if ! wget --quiet --continue --show-progress --progress=bar:force:noscroll "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${PROTON_VER}/Proton-${PROTON_VER}.tar.gz" -O "${TM_PATH}/Proton-${PROTON_VER}.tar.gz"; then
  echo "ERROR! Failed to download Proton-${PROTON_VER}.tar.gz. Try running ${0} again."
  exit 1
fi

# Unpack Proton
if [ ! -d "${TM_PATH}/Proton/Proton-${PROTON_VER}" ]; then
  echo "Unpacking Proton-${PROTON_VER}.tar.gz"
  tar -xf "${TM_PATH}/Proton-${PROTON_VER}.tar.gz" -C "${TM_PATH}/Proton/"
fi

# Determine where the wine executables are
for BIN in dist files; do
  if [ -d "${TM_PATH}/Proton/Proton-${PROTON_VER}/${BIN}/bin" ]; then
    PROTON_PATH="${TM_PATH}/Proton/Proton-${PROTON_VER}/${BIN}/bin"
    break
  fi
done

if [ -z "${PROTON_PATH}" ]; then
  echo "ERROR! Could not find wine executable"
  ls -l "${TM_PATH}/Proton/Proton-${PROTON_VER}/"
  exit 1
fi

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
