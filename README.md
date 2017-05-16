# OpenVPN tool

Easier and secure Open VPN.

This is not ideal as it still bounces the username/password off disk, to pass it over to openvpn.

## Setup Fedora/CentOS/RHEL Host

	dnf -y install openvpn gpg
	cp update-resolv-conf /etc/openvpn/update-resolv-conf
	chmod 755 /etc/openvpn/update-resolv-conf
	cp vpnstart ~/bin

## Setup A key

	mkdir ~/.ovpn

Put your config and files in this location.  Supports multiple config, with the config/token name being the {name}.ovpn.

### Setup secured auth delegation

vpnstart supports wrapping a username/password with a one time password (OTP/MFA), where this file is secured with gpg encryption.  You can easily generate this file with vpnstart (if authpass.txt is your auth credentials file):

	vpnstart --newauth authpass.txt

And the tool will take care of the rest.  If you want to create it by hand, you can do it as well.  First, create a base file such as `authpass.txt` and format it as:

	username
	password%{OTP}

Of course with your username and password.  The %{OTP} section will be replaced with your one time password for MFA each time it is run.

Then encrypt this file with a strong passphrase (multiple character types, over 32 chars in length):

	gpg -c onelogin.auth

Add to your configuration ({name}.ovpn)

	auth-user-pass authpass.txt
	up /etc/openvpn/update-resolv-conf
	down /etc/openvpn/update-resolv-conf
	script-security 2
