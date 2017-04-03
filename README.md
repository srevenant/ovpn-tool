# OpenVPN tool

Easier and secure Open VPN.

This is not ideal as it still bounces the username/password off disk, to pass it over to openvpn.

## Setup Fedora/CentOS/RHEL Host

	dnf -y install openvpn gpg
	cp update-resolv-conf /etc/openvpn/update-resolv-conf
	chmod 755 /etc/openvpn/update-resolv-conf
	cp vpnstart ~/bin

## Setup MacOS/Darwin Host

	brew install openvpn gpg
	cp update-resolv-conf /etc/openvpn/update-resolv-conf
	chmod 755 /etc/openvpn/update-resolv-conf
	cp vpnstart ~/bin

## Setup A key

	mkdir ~/.ovpn

Put your key and files in this location.  Supports multiple keys, with the key/token name being the {name}.ovpn (in all cases replace {name} with your key name, such as 'prod').

create {name}.auth formatted as:

	username
	password%{OTP}

The %{OTP} section will be replaced with your one time password for MFA, at each run time.

Encrypt the resulting file with the following (use a strong pass phrase):

	gpg -c {name}.auth

Add to {name}.ovpn:

	auth-user-pass {name}.auth
	up /etc/openvpn/update-resolv-conf
	down /etc/openvpn/update-resolv-conf
	script-security 2
