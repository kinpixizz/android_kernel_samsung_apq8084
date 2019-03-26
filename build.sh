#!/bin/bash


###########################################
#                                         #
#  "The bulk of the ideas behind this     #
#   script were taken from halaszk's      #
#   build_kernel.sh and env_setup.sh      #
#   scripts. I just rearranged them to    #
#   fit my needs." -kevintm78             #
#                                         #
###########################################


# Colorize and add text parameters
export red=$(tput setaf 1)             #  red
export grn=$(tput setaf 2)             #  green
export blu=$(tput setaf 4)             #  blue
export cya=$(tput setaf 6)             #  cyan
export txtbld=$(tput bold)             #  Bold
export bldred=${txtbld}$(tput setaf 1) #  red
export bldgrn=${txtbld}$(tput setaf 2) #  green
export bldblu=${txtbld}$(tput setaf 4) #  blue
export bldcya=${txtbld}$(tput setaf 6) #  cyan
export txtrst=$(tput sgr0)             #  Reset



# check if ccache installed, if not install
if [ ! -e /usr/bin/ccache ]; then
	echo "You must install 'ccache' to continue.";
	sudo apt-get install ccache
fi

# check if xmllint installed, if not install
if [ ! -e /usr/bin/xmllint ]; then
	echo "You must install 'xmllint' to continue.";
	sudo apt-get install libxml2-utils
fi

echo "${bldgrn}***** Extended Battery Patch *****${txtrst}";


read -t 10 -p "Add extended battery patch (y/n)?";
if [ "$REPLY" == "y" ]; then
cp $(pwd)/extended-patch/max77843_fuelgauge.c-patched $(pwd)/drivers/battery/max77843_fuelgauge.c
fi

if [ "$REPLY" == "n" ]; then
cp $(pwd)/extended-patch/max77843_fuelgauge.c $(pwd)/drivers/battery/max77843_fuelgauge.c
fi

echo "${bldcya}***** Clean up Environment before compile *****${txtrst}";


# Make clean source
read -t 10 -p "Make clean source, 10sec timeout (y/n)?";
if [ "$REPLY" == "y" ]; then
rm -rf AnyKernel2/dtb
rm -rf AnyKernel2/zImage
rm -rf AnyKernel2/modules/system/lib/modules/*.ko
rm -rf output/
make clean
make mrproper
fi


# set build variables
export ARCH=arm
export SUB_ARCH=arm
mkdir output

#################################### Toolchain #########################################

export CROSS_COMPILE=/home/kevintm78/Toolchains/arm-eabi-5.3/bin/arm-eabi-





#################################### Defconfig Options ####################################
echo
echo "${bldblu}***** Compiling kernel *****${txtrst}"

make -C $(pwd) O=output VARIANT_DEFCONFIG=apq8084_sec_trlte_eur_defconfig apq8084_sec_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -j$( nproc --all ) -C $(pwd) O=output 





###################################### AnyKernel2 #####################################

cp output/arch/arm/boot/zImage $(pwd)/AnyKernel2/zImage
./tools/dtbTool -o ./AnyKernel2/dtb -s 4096 -p ./output/scripts/dtc/ ./output/arch/arm/boot/dts/
for i in $(find "output" -name '*.ko'); do
	cp -av "$i" ./AnyKernel2/modules/system/lib/modules/

done;

echo
echo "${bldcyn}***** Making AnyKernel Zip  *****${txtrst}"

cd AnyKernel2
	zip -r9 Flashpoint_Pie.zip * -x .git README.md *placeholder *.zip

echo
echo "Build completed"
echo
echo "${bldgrn}***** Flashable zip found in AnyKernel2 directory *****${txtrst}"
echo
 