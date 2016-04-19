#!/bin/sh
# Get ss server IP address and password from user input
echo "Please enter your SS server IP address:"
read ip_address

echo "Please enter your SS server password:"
read password

# Set up config.json
cat <<EOF >> config.json
{
 	"server": "$ip_address",
 	"server_port": 8388,
	"local_port": 1080,
	"password": "$password",
	"timeout": 600,
	"method": "aes-256-cfb"
}
EOF

# Copy shadowsocks config.json file to remote server
scp ./config.json root@$ip_address:/root
rm config.json

# Access to remote server and run the following commands remotely
ssh root@$ip_address << EOF
	# Shadowsocks server installation script
	apt-get update;
	# Install python environment
	apt-get install python-gevent python-pip -y;
	# Install shadowsocks
	pip install shadowsocks;
	# Create shadowsocks config.json file directory
	mkdir /etc/shadowsocks;
	cp /root/config.json /etc/shadowsocks/;
	rm /root/config.json;
	# Install encryption python package
	apt-get install python-m2crypto;
	# Make ssserver running at system start up
	# echo "/usr/local/bin/ssserver -c /etc/shadowsocks/config.json" >> /etc/rc.local
	# Start ssserver service
	nohup ssserver -c /etc/shadowsocks/config.json > log &
EOF
