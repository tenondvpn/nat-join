#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
min_port=$(($1+0))
max_port=$(($2+0))
sp_port=$(($min_port+1))
sp_min_port=$(($min_port+2))
echo $min_port $max_port $sp_port $sp_min_port
cp -rf ./node/conf/lego.conf_bak ./node/conf/lego.conf
sed -i -e 's/rep_lp/'$min_port'/g' ./node/conf/lego.conf
sed -i -e 's/rep_sp/'$sp_port'/g' ./node/conf/lego.conf
sed -i -e 's/rep_max/'$max_port'/g' ./node/conf/lego.conf
sed -i -e 's/rep_min/'$sp_min_port'/g' ./node/conf/lego.conf
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

install() {
    if [[ "${release}" == "centos" ]]; then
	sudo sh centos_env.sh
    else
        sudo bash general_env.sh
    fi
}

check_sys
install
