#!/bin/bash

# Basic imports

option=$1
parameter=$2
parameter2=$3
version=1.0

disable_done=False


bold=$(tput bold)
normal=$(tput sgr0)

Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# YAML parser

function parse_yaml {
      local prefix=$2
      local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
      sed -ne "s|^\($s\):|\1|" \
            -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
      awk -F$fs '{
            indent = length($1)/2;
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
            if (length($3) > 0) {
                  vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                  printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
            }
      }'
}

eval "$(parse_yaml config.yaml "CONFIG_")"

flatpak_check=$(echo "$CONFIG_package_managers_flatpak")
flatpak=$(echo $flatpak_check)
snap_check=$(echo "$CONFIG_package_managers_snapcraft")
snap=$(echo $snap_check)
yum_check=$(echo "$CONFIG_package_managers_yum")
yum=$(echo $yum_check)
pacman_check=$(echo "$CONFIG_package_managers_pacman")
pacman=$(echo $pacman_check)
cargo_check=$(echo "$CONFIG_package_managers_cargo")
cargo=$(echo $cargo_check)
dnf_check=$(echo "$CONFIG_package_managers_dnf")
dnf=$(echo $dnf_check)
apt_check=$(echo "$CONFIG_package_managers_apt")
apt=$(echo $apt_check)
zypp_check=$(echo "$CONFIG_package_managers_zypp")
zypp=$(echo $zypp_check)

# Start jobs

if [ "$option" == "" ]; then
      echo -e "${BRed}_________                       .__            
\_   ___ \_______  ____   _____ |  |__ _____   
/    \  \/\_  __ \/  _ \ /     \|  |  \\__  \  
\     \____|  | \(  <_> )  Y Y  \   Y  \/ __ \_
 \______  /|__|   \____/|__|_|  /___|  (____  /
        \/                    \/     \/     \/ 
${Color_Off}"
      echo " "
      echo "${bold}=====================================================================${normal}"
      echo -e "${BPurple}Github Repository${Color_Off}: ${BBlue}https://github.com/OcelotWalrus/Bash-Multi-Package-Manager${Color_Off}"
      echo " "
      echo -e "${Green}Current version${Color_Off}: ${BYellow}$version${Color_Off}"
      echo "${bold}=====================================================================${normal}"
      echo " "
      echo -e "${Cyan}A bash script to manage multiple package
managers easily with high customizability.${Color_Off}"
      echo " "
      echo "Tip: run '$ sh cromha_manager.sh help'"
      disable_done=True
fi

if [ $disable_done == False ]; then
      echo "${bold}Note that this operation can take multiple minutes"
      echo " "
fi

# Options

if [ "$option" == "autoremove" ]; then
      echo "Autoremoving packages..."
      if [ $flatpak == True ]; then
            sudo flatpak uninstall -y --unused >&- 2>&-
            echo "[Autoremoving Flatpak Packages]"
            sh src/progress_bar.sh
      fi
      if [ $snap == True ]; then
            set -eu
            LANG=C snap list --all | awk '/disabled/{print $1, $3}' |
            while read snapname revision; do
                  sudo snap remove "$snapname" --revision="$revision" >&- 2>&-
            done
            echo "[Autoremoving Snapcraft Packages]"
            sh src/progress_bar.sh
      fi
      if [ $yum == True ]; then
            sudo yum autoremove -y >&- 2>&-
            echo "[Autoremoving Yum Packages]"
            sh src/progress_bar.sh
      fi
      if [ $pacman == True ]; then
            echo ${bold}ERROR: Sorry but pacman autoremove is not yet supported${normal}
      fi
      if [ $cargo == True ]; then
            echo ${bold}ERROR: Sorry but cargo autoremove is not yet supported${normal}
      fi
      if [ $dnf == True ]; then
            sudo dnf autoremove -y >&- 2>&-
            echo "[Autoremoving Dnf Packages]"
            sh src/progress_bar.sh
      fi
      if [ $apt == True ]; then
            sudo apt autoremove -y >&- 2>&-
            echo "[Autoremoving APT Packages]"
            sh src/progress_bar.sh
      fi
      if [ $zypp == True ]; then
            echo ${bold}ERROR: Sorry but zypper autoremove is not yet supported${normal}
      fi
fi

if [ "$option" == "upgrade" ] || [ "$option" == "update" ]; then
      echo "Checking for package managers updates..."
      sleep 3
      echo "Updating different package managers..."
      if [ $flatpak == True ]; then
            sudo flatpak update -y >&- 2>&-
            echo "[Updating Flatpak Packages]"
            sh src/progress_bar.sh
      fi
      if [ $snap == True ]; then
            sudo snap refresh >&- 2>&-
            echo "[Updating Snapcraft Packages]"
            sh src/progress_bar.sh
      fi
      if [ $yum == True ]; then
            sudo yum update -y >&- 2>&-
            echo "[Updating Yum Packages]"
            sh src/progress_bar.sh
      fi
      if [ $pacman == True ]; then
            sudo pacman -Syu >&- 2>&-
            echo "[Updating Pacman Packages]"
            sh src/progress_bar.sh
      fi
      if [ $cargo == True ]; then
            sudo cargo update -y >&- 2>&-
            echo "[Updating Cargo Packages]"
            sh src/progress_bar.sh
      fi
      if [ $dnf == True ]; then
            sudo dnf update -y >&- 2>&-
            echo "[Updating Dnf Packages]"
            sh src/progress_bar.sh
      fi
      if [ $apt == True ]; then
            sudo apt update -y >&- 2>&-
            echo "[Updating APT Packages]"
            sh src/progress_bar.sh
      fi
      if [ $zypp == True ]; then
            sudo zypper update -y >&- 2>&-
            echo "[Updating Zypp Packages]"
            sh src/progress_bar.sh
      fi
fi

if [ "$option" == "help" ]; then
	echo "${bold}HELP PAGE:"
	echo " "
	echo "${bold}OPTIONS${normal} (First entry):"
	echo " "
	echo "${bold}autoremove${normal}: remove all unneeded packages that were originally installed as dependencies"
	echo "${bold}help${normal}: show this page"
	echo "${bold}upgrade/update${normal}: update your system"
      echo "${bold}customize${normal}: customize config.yaml"
	echo " "
	echo "${bold}PARAMETERS${normal} (Second and Third entry):"
	echo " "
	echo "${bold}-clean${normal}: clean cashed data after executing option"
	echo "${bold}-exit${normal}: close terminal window after executing option"
	echo "${bold}-poweroff${normal}: poweroff your system after executing option (alias: -shutdown)"
	echo "${bold}-reboot${normal}: reboot your system after executing option (alias: -restart)"
	echo "${bold}-restart${normal}: restart your system after executing option (alias: -reboot)"
	echo "${bold}-shutdown${normal}: shutdown your system after executing option (alias: -poweroff)"
      echo " "
      echo "${bold}CUSTOMIZATION:"
      echo "${bold}customize${normal}: customize config.yaml"
      echo "Go to: https://github.com/OcelotWalrus/Bash-Multi-Package-Manager for more information"
	disable_done=True
fi

if [ "$option" == "customize" ]; then
      echo Opening config.yaml...
      sleep 1
      nano config.yaml
fi

# Parameters

# First

if [ "$parameter" == "-clean" ]; then
	echo "Cleaning cashed data..."
	sudo dnf clean all -y
fi

if [ "$parameter" == "-exit" ]; then
	echo "Closing terminal window..."
	kill -9 $PPID
fi

if [ "$parameter" == "-poweroff" ] || [ "$parameter" == "-shutdown" ]; then
	echo "Shutingdown your system in 15 seconds..."
	sleep 15
	sudo poweroff
fi

if [ "$parameter" == "-reboot" ] || [ "$parameter" == "-restart" ]; then
	echo "Rebooting your system in 15 seconds..."
	sleep 15
	sudo reboot
fi

# Second

if [ "$parameter2" == "-clean" ]; then
	echo "Cleaning cashed data..."
	sudo dnf clean all -y
fi

if [ "$parameter2" == "-exit" ]; then
	echo "Closing terminal window..."
	kill -9 $PPID
fi

if [ "$parameter2" == "-poweroff" ]; then
	echo "Shutingdown your system in 15 seconds..."
	sleep 15
	sudo poweroff
fi

if [ "$parameter2" == "-reboot" ]; then
	echo "Rebooting your system in 15 seconds..."
	sleep 15
	sudo reboot
fi

if [ "$parameter2" == "-restart" ]; then
	echo "Restarting your system in 15 seconds..."
	sleep 15
	sudo reboot
fi

if [ "$parameter2" == "-shutdown" ]; then
	echo "Shutingdown your system in 15 seconds..."
	sleep 15
	sudo shutdown
fi

# End jobs

if [ $disable_done == False ]; then
      echo -e $Color_Off $bold Done !
fi
