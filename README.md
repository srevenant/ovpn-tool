# vpnstart

Easy and simple openvpn wrapper to handle MFA and multiple keys, in Linux.

This is not ideal as it still bounces the username/password off disk, to pass it over to openvpn, but it keeps it encrypted otherwise.

## Setup Fedora/CentOS/RHEL Host

Install:

1. Install the software

    	dnf -y install openvpn gpg
    	curl -LOfs http://vpnstart.cold.org/get.sh && sudo bash ./get.sh

2. Put your openvpn configs & certs into ~/.ovpn.  Supports {name}.ovpn, can handle multiple profiles.

3. Setup your secured password (encrypted w/pgp) - this is referenced in your {name.ovpn} config file as `auth-user-pass authpass.txt`:

    	vpnstart --newauth ~/.ovpn/authpass.txt

    (see note below for more info)

4. Run vpnstart:

        vpnstart {name}


## A note on wrapping password

`vpnstart` supports wrapping a username/password with a one time password (OTP/MFA), where this file is secured with gpg encryption.  You generate and change this file with `vpnstart --newauth ~/.ovpn/file`.

The tool takes care of the rest.  If you want to create it by hand, you can do it as well.  First, create a base file such as `authpass.txt` and format it as:

	username
	password%{OTP}

Of course, with your username and password.  The %{OTP} section will be replaced with your one time password for MFA each time it is run.

Then encrypt this file with a strong passphrase (multiple character types, over 32 chars in length):

	gpg -c authpass.txt

Add to your configuration ({name}.ovpn)

	auth-user-pass authpass.txt
	up /etc/openvpn/update-resolv-conf
	down /etc/openvpn/update-resolv-conf
	script-security 2

You can also inspect the contents of this file with:

    gpg -d authpass.txt

## Development Notes

Manual install:

	dnf -y install openvpn gpg

	cp update-resolv-conf /etc/openvpn/update-resolv-conf
	chmod 755 /etc/openvpn/update-resolv-conf
	cp vpnstart /usr/local/bin
	chmod 755 /usr/local/bin/vpnstart
