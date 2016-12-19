#!/bin/bash

PACKAGENAME=syncthing-ubuntu-indicator
VERSION=1.0.0
MAINTAINER=
EMAIL=

echo "Build $PACKAGENAME.deb"

mkdir -p "$PACKAGENAME/usr/bin" "$PACKAGENAME/etc/xdg/autostart" "$PACKAGENAME/usr/bin" "$PACKAGENAME/usr/share/syncthing-ubuntu-indicator"

wget -nc -O - "https://github.com/vincent-t/syncthing-ubuntu-indicator/archive/master.tar.gz" | tar -xvzf - -C $PACKAGENAME/usr/share/syncthing-ubuntu-indicator --strip-components=1 --exclude='README.md' --exclude='make_deb.sh' --exclude="*.gitignore" --exclude="*.svg"

tee "$PACKAGENAME/etc/xdg/autostart/syncthing-ubuntu-indicator.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=syncthing-ubuntu-indicator
Comment=AppIndicator for Syncthing
Exec=syncthing-ubuntu-indicator --loglevel warning
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

#Create softlink
ln -s "/usr/share/syncthing-ubuntu-indicator/syncthing-ubuntu-indicator.py" "$PACKAGENAME/usr/bin/syncthing-ubuntu-indicator"

PACKAGESIZE=$(du -c $PACKAGENAME | egrep -i 'total|insgesamt' | cut -f1)

mkdir "$PACKAGENAME/DEBIAN"
tee "$PACKAGENAME/DEBIAN/control" << EOF
Package: $PACKAGENAME
Version: $VERSION
Architecture: all
Maintainer: $MAINTAINER <$EMAIL>
Installed-Size: $PACKAGESIZE
Depends: python3-dateutil, python3-gi, python3-requests, python3-requests-futures, python3-tz
Section: python
Priority: optional
Homepage: https://github.com/vincent-t/syncthing-ubuntu-indicator
Description: syncthing-ubuntu-indicator
 Provides an AppIndicator for Syncthing
EOF

chmod 0644 "$PACKAGENAME/DEBIAN/control"

fakeroot dpkg-deb --build "$PACKAGENAME"
rm -rf "$PACKAGENAME"
echo "$PACKAGENAME.deb successfully build!"
