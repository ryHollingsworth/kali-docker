FROM kalilinux/kali-rolling

ARG KALI_PROFILE=kali-linux-default
ARG KALI_PASSWORD=##### #defaults-override with a env/var file
ARG ROOT_PASSWORD=#####

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV LANG=en_US.UTF-8

# Update system and install required packages
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies tightvncserver sudo \
    websockify novnc net-tools curl git wget \
    ssl-cert dbus-x11 firefox-esr \
    ${KALI_PROFILE} \
    && apt-get clean

# Fix UTF-8 support, prompt, and keyboard layout
RUN apt-get update && apt-get install -y \
    locales fonts-dejavu fonts-liberation2 fonts-noto-core console-setup && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 && \
    echo 'XKBLAYOUT="us"' > /etc/default/keyboard && \
    apt-get clean

# Add user 'kali' with sudo and set passwords
RUN useradd -m -s /bin/bash kali && \
    echo "kali ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "kali:${KALI_PASSWORD}" | chpasswd && \
    echo "root:${ROOT_PASSWORD}" | chpasswd

# Set simple, UTF-8 safe bash prompt
RUN echo "export PS1='\\u@\\h:\\w\\$ '" >> /home/kali/.bashrc && \
    chown kali:kali /home/kali/.bashrc

# VNC directory
RUN mkdir -p /home/kali/.vnc && chown kali:kali /home/kali/.vnc
#RUN mkdir -p /root/.vnc

# Add startup script
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

# Expose noVNC (6080) port
EXPOSE 6080

# Launch noVNC
CMD ["/opt/start.sh"]
