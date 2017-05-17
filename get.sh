#!/usr/bin/env bash
#
# some parts shamelessly borrowed from NVM
#

{ # this ensures the entire script is downloaded #

msg() {
	echo >&2 "$@"
}

host_has() {
  type "$1" > /dev/null 2>&1
}

download() {
  echo "getting $(basename $1)"
  if host_has "curl"; then
    curl -L -q -s $*
  elif host_has "wget"; then
    # Emulate curl with wget
    ARGS=$(echo "-s $*" | command sed -e 's/--progress-bar /--progress=bar /' \
                           -e 's/-L //' \
                           -e 's/-I /--server-response /' \
                           -e 's/-s /-q /' \
                           -e 's/-o /-O /' \
                           -e 's/-C - /-c /')
    wget $ARGS
  fi
}

die() {
	echo >&2 $*
	exit 1
}

cmd() {
	label="$1"
	shift

	if [ -n "$label" ]; then
		msg "$label"
	fi

	"$@" || {
		echo >&2 "Unable to run: $@"
		exit 1
	}
}

has_cmd() {
    name="$1"
	if ! host_has $name ; then
		cat <<END

--> Pre-Requisite: You need \`$name\`
END
		let errs++
	fi
}

if [ ! -d ~/.ovpn ]; then
    mkdir ~/.ovpn
    chmod 700 ~/.ovpn
fi

################
# prep
echo ""
echo "=> Checking environment..."
errs=0

has_cmd perl
if has_cmd python; then
    if has_cmd pip; then
        if ! python -c 'import requests' >/dev/null 2>&1; then
        	echo "installing requests module..."
        	pip install requests
        fi
    fi
fi
if [ $errs -gt 0 ]; then
	exit 1
fi

################
gitraw=https://raw.github.com/srevenant/ovpn-tool/master/
echo ""
echo -n "=> Installing..."
download $gitraw/ver -o .ver > /dev/null
cat .ver
rm .ver

if [ ! -d ~/.ovpn ]; then
	mkdir ~/.ovpn
fi
rm -f ~/.ovpn/.latest
rm -f /usr/local/bin/vpnstart /etc/openvpn/update-resolv-conf
download $gitraw/vpnstart -o /usr/local/bin/vpnstart
chmod 755 /usr/local/bin/vpnstart
download $gitraw/update-resolv-conf -o /etc/openvpn/update-resolv-conf
chmod 755 /etc/openvpn/update-resolv-conf


echo ""
echo "=> Done"
echo ""

} # this ensures the entire script is downloaded #

