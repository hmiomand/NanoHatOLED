#! /bin/bash
#
# modified by Maarten
echo "BakeBit installer for FriendlyARM NanoHatOLED"
echo ""
echo "Requirements:"
echo "- active internet connection"
echo "- run this script as root user"
echo ""
echo "Steps:"
echo "Install packages:"
echo "   - python3.11        Interactive high-level object-oriented language (version 3.11)"
echo "   - python3-dev      header files and a static library for Python (default)"
echo "   - python3-pip      Python package installer"
echo "   - python3-smbus    Python bindings for Linux SMBus access through i2c-dev"
echo "   - i2c-tools        heterogeneous set of I2C tools for Linux"
echo "   - libi2c-dev       userspace I2C programming library development files"
echo "   - libfreetype6-dev FreeType 2 font engine, development files"
echo "   - libjpeg-dev      Development files for the JPEG library [dummy package]"
echo ""
echo "Install python modules:"
echo "   - python setuptools"
echo "   - python pip"
echo "   - python image"
echo "   - python pillow"
echo "   - python luma.oled"
echo "   - python RPI.GPIO"
echo ""
echo "Make builds:"
echo "   - WiringNP         A GPIO access library for NanoPi NEO"
echo ""
echo "NanoPi will reboot after completion"
echo ""
echo ""
sleep 5

echo "Check for internet connectivity..."
echo "=================================="
wget -q --tries=2 --timeout=30 http://www.icann.org -O /dev/null
if [ $? -eq 0 ]; then
    echo "Connected"
else
    echo "Unable to connect, try again"
	exit 0
fi

USER_ID=$(/usr/bin/id -u)
USER_NAME=$(/usr/bin/who am i | awk '{ print $1 }')
SCRIPT_PATH=$(/usr/bin/realpath $0)
DIR_PATH=$(/usr/bin/dirname ${SCRIPT_PATH} | sed 's/\/Script$//')

if [ ${USER_ID} -ne 0 ]; then
    echo "Please run this as root."
    exit 1
fi

echo ""
echo " Checking For updates  "
sudo apt-get update --yes
echo "======================="

echo ""
echo "Installing packages"
echo "======================="
sudo apt-get install python3.11 python3-dev python3-pip python3-smbus git i2c-tools libi2c-dev libfreetype6-dev libjpeg-dev -y
echo "Packages installed"
yes | pip3 install --upgrade --force-reinstall --ignore-installed pip
yes | pip3 install --upgrade setuptools
yes | pip3 install --upgrade pip
yes | pip3 install --upgrade image
yes | pip3 install --upgrade pillow
yes | pip3 install --upgrade luma.oled
yes | pip3 install --upgrade RPI.GPIO
echo "Python modules installed"

echo "Building WiringNP"
if [ -d WiringNP ]; then
    cd WiringNP
else
    git clone https://github.com/friendlyarm/WiringNP.git
    cd WiringNP
fi

sudo ./build
RES=$?

if [ $RES -ne 0 ]; then
    echo "Something went wrong building/installing WiringNP, exiting."
    exit 1
fi
echo "WiringNP suceesfully built and installed"

sudo adduser ${USER_NAME} i2c

echo ""
echo "Making libraries global . . ."
echo "============================="
if [ -d /usr/local/lib/python3.11/dist-packages ]; then
    echo "${DIR_PATH}/Software/Python/" > /usr/local/lib/python3.11/dist-packages/bakebit.pth
else
    echo "/usr/lib/python3.11/dist-packages not found, exiting"
    exit 1
fi

echo "System must reboot for changes and updates to take effect"
echo "If you need to abort the reboot, press Ctrl+C"
echo ""
echo "Rebooting in 5 seconds"
sleep 1
echo "Rebooting in 4 seconds"
sleep 1
echo "Rebooting in 3 seconds"
sleep 1
echo "Rebooting in 2 seconds"
sleep 1
echo "Rebooting in 1 second"
sleep 1
echo "Rebooting now"
sleep 1
sudo reboot
