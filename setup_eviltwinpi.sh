#!/bin/bash
setup() {
	
	echo '[*] Creating bridge...'
	brctl addbr br0
	brctl addif br0 $ethernet
	brctl addif br0 $wireless
	echo '[+] Bridge was successfully created'

	rm -f /etc/hostapd/hostapd.conf #Remove this just in case it already exists
	cp hostapd.conf /etc/hostapd/
	cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.backup
		
	sed -i "s/interface=wlan1/interface=$wireless/g" /etc/hostapd/hostapd.conf
	sed -i "s/ssid=EnterWifiHere/ssid=$ap/g" /etc/hostapd/hostapd.conf
		
	rm -f /etc/dnsmasq.conf
	cp dnsmasq.conf /etc/dnsmasq.conf
	cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

	sed -i "s/interface=wlan1/interface=$wireless/g" /etc/dnsmasq.conf
	sed -i "s/iface br0 inet manual/iface br0 inet manual/g" interfaces
	sed -i "s/bridge_ports eth0 wlan1/bridge_ports $ethernet $wireless/g" interfaces
	
	rm -f /etc/wpa_supplicant/wpa_supplicant.conf 
	cp wpa_supplicant.conf /etc/wpa_supplicant/
	cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.backup

	/etc/init.d/dnsmasq start
	/etc/init.d/hostapd start
	echo "[*] Make sure you change the default AP password in /etc/hostapd/hostapd.conf"
}

check_install() {
	sudo apt-get update -y > /dev/null | echo '[*] Updating the repository...'
	sudo apt-get install hostapd dnsmasq -y > /dev/null | echo '[*] Downloading configuration files...'
	setup
}

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 0
else
	if [[ $# -ne ]]; then
		echo "[-] Usage: ./setup_eviltwinpi.sh [wireless int] [ethernet int] [access point name] "
	else
		wireless=$1
		ethernet=$2
		ap=$3
		check_install
	fi
fi
