#!/bin/bash

# Default fallback values
# Override default passwords in env/var files
export USER=root
VNC_PASSWORD=${VNC_PASSWORD:-#####}
KALI_PASSWORD=${KALI_PASSWORD:-#####}
ROOT_PASSWORD=${ROOT_PASSWORD:-#####}

# Set user passwords securely
echo "Setting kali and root user passwords..."
echo "kali:$KALI_PASSWORD" | chpasswd
echo "root:$ROOT_PASSWORD" | chpasswd

# Setup .vnc directory and password for kali
mkdir -p /home/kali/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/kali/.vnc/passwd
chmod 600 /home/kali/.vnc/passwd
chown -R kali:kali /home/kali/.vnc

# Start the VNC server as user 'kali'
echo "Starting VNC server as user kali..."
su - kali -c "vncserver :1 -geometry 1280x800 -depth 24"

# Start noVNC as root (uses the VNC session)
echo "Launching noVNC on port 6080..."
cd /usr/share/novnc
ln -sf vnc.html index.html

/usr/bin/websockify --web=/usr/share/novnc/ \
  6080 localhost:5901 &

# Keep container alive
tail -f /dev/null
