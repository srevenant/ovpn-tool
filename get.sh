#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

msg() {
	echo >&2 "$@"
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

host_has() {
  type "$1" > /dev/null 2>&1
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

################
# prep
echo ""
echo "=> Checking environment..."

# support a few diff pkg managers
if host_has yum; then
    pkgs="gpg openvpn python python2-pip"
    echo "=> Enabling epel-release..."
    yum -y install epel-release > /dev/null 2>&1

    pkg_add() {
      if ! rpm -q $1 >/dev/null 2>&1; then
          echo "=> Installing missing prerequisite package '$1'"
          yum -y install $1 || exit 1
      fi
    }
elif host_has apt; then
    did_update=
    pkg_add() {
      if ! dpg -l $1 >/dev/null 2>&1; then
          if [ ! $did_update ]; then
              did_update=1
              apt update
          fi
          echo "=> Installing missing prerequisite package '$1'"
          apt -y install $1 || exit 1
      fi
    }
    pkgs="gpgv2 openvpn python python-pip"
else
    echo "Cannot determine package manager type (supports yum and apt)"
    exit 1
fi

errs=0
for pkg in $pkgs; do
    pkg_add $pkg
done

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

if [ ! -d ~/.ovpn ]; then
    mkdir ~/.ovpn
    chmod 700 ~/.ovpn
fi

################
gitraw=https://raw.github.com/srevenant/vpnstart/master/
echo ""
echo -n "=> Installing..."
download $gitraw/ver -o .ver > /dev/null
cat .ver
rm .ver

if [ -n "$SUDO_USER" ]; then
    ovpn=$(eval echo ~$SUDO_USER/.ovpn)
    if [ ! -d $ovpn ]; then
    	mkdir $ovpn
    fi
    rm -f $ovpn/.latest
fi

rm -f /usr/local/bin/vpnstart /etc/openvpn/update-resolv-conf
download $gitraw/vpnstart -o /usr/local/bin/vpnstart
chmod 755 /usr/local/bin/vpnstart
download $gitraw/update-resolv-conf -o /etc/openvpn/update-resolv-conf
chmod 755 /etc/openvpn/update-resolv-conf

echo ""
echo "=> Done"
echo ""

} # this ensures the entire script is downloaded #

