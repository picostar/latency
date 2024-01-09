# docker build -t openwrt .
# docker run --network host -v goodstuff:/root -it openwrt /bin/sh
# 
# docker ps -a
# docker start fbf72b740694
# docker attach fbf72b740694
#
# Use an existing docker image as a base
FROM openwrt/rootfs

# Set the working directory in the container
WORKDIR /home

# Copy the current directory contents into the container at /home
# COPY . .

# Make port 80 available to the world outside this container
# EXPOSE 80


RUN mkdir /var/lock && \
    opkg update && \
    opkg install lua tar node tcpdump nmap uhttpd-mod-lua luci-lib-nixio && \
#   tar and node are needed for VS code docker extension.... remove otherwise
    uci set uhttpd.main.interpreter='.lua=/usr/bin/lua' && \
    uci commit uhttpd && \
    rm -rf /var/lib/opkg/lists/*

USER roots

# using exec format so that /sbin/init is proc 1 (see procd docs)
CMD ["/sbin/init"]

# Run the command inside your image filesystem
# CMD ["make", "menuconfig"]