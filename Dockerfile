# Use Debian Bookworm Slim as the base image
FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    python3 \
    python3-pip \
    xvfb \
    virtualbox \
    x11vnc \
    x11-utils \
    xauth \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone https://github.com/novnc/websockify.git /opt/websockify \
    && pip3 install websockify

# Create the start script
RUN echo '#!/bin/bash\n\
\n\
# Start the virtual framebuffer\n\
Xvfb :0 -screen 0 1280x720x24 &\n\
\n\
# Set the DISPLAY environment variable\n\
export DISPLAY=:0\n\
\n\
# Start the VNC server\n\
x11vnc -display :0 -nopw -forever -repeat &\n\
\n\
# Start VirtualBox GUI\n\
/usr/bin/virtualbox &\n\
\n\
# Start websockify to bridge to noVNC\n\
/opt/websockify/run 6080 --web=/opt/noVNC 5901 &\n\
\n\
# Keep the script running\n\
wait' > /start.sh

# Make the script executable
RUN chmod +x /start.sh

# Expose necessary ports
EXPOSE 6080 5901

# Command to start the services
CMD ["/start.sh"]
