#!/bin/bash
check_system(){
    [[ -z "`cat /etc/issue | grep -iE "debian"`" ]] && echo -e "${Error} only support Debian !" && exit 1
}

check_root(){
    [[ "`id -u`" != "0" ]] && echo -e "${Error} must be root user !" && exit 1
}

check_kvm(){
    apt-get update
    apt-get install -y virt-what
    apt-get install -y ca-certificates
}

install_image(){
    bit=`uname -m`
    if [[ "${bit}" = "x86_64" ]]; then
        echo -e "${Info} installing image" && dpkg -i ./pkgs/debian9/linux-image_amd64.deb
    elif [[ "${bit}" = "i386" ]]; then
        echo -e "${Info} installing image" && dpkg -i ./pkgs/debian9/linux-image_i386.deb
    else
        echo -e "${Error} not support bit !" && exit 1
    fi
}

delete_surplus_image(){
    for((integer = 1; integer <= ${surplus_total_image}; integer++))
    do
         surplus_sort_image=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "4.10.2" | head -${integer}`
         apt-get purge -y ${surplus_sort_image}
    done
    apt-get autoremove -y
    if [[ "${surplus_total_image}" = "0" ]]; then
         echo -e "${Info} uninstall all surplus images successfully, continuing"
    fi
}

delete_surplus_headers(){
    for((integer = 1; integer <= ${surplus_total_headers}; integer++))
    do
         surplus_sort_headers=`dpkg -l|grep linux-headers | awk '{print $2}' | grep -v "4.10.2" | head -${integer}`
         apt-get purge -y ${surplus_sort_headers}
    done
    apt-get autoremove -y
    if [[ "${surplus_total_headers}" = "0" ]]; then
         echo -e "${Info} uninstall all surplus headers successfully, continuing"
    fi
}

#check/install required version and remove surplus kernel
check_kernel(){
    #when kernel version = required version, response required version number.
    digit_ver_image=`dpkg -l | grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep "4.10.2"`

    #total digit of kernel without required version
    surplus_total_image=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "4.10.2" | wc -l`
    surplus_total_headers=`dpkg -l|grep linux-headers | awk '{print $2}' | grep -v "4.10.2" | wc -l`

    if [[ -z "${digit_ver_image}" ]]; then
        echo -e "${Info} installing required image" && install_image
    else
        echo -e "${Info} image already installed a required version"
    fi

    if [[ "${surplus_total_image}" != "0" ]]; then
         echo -e "${Info} removing surplus image" && delete_surplus_image
    else echo -e "${Info} no surplus image need to remove"
    fi

    if [[ "${surplus_total_headers}" != "0" ]]; then
         echo -e "${Info} removing surplus headers" && delete_surplus_headers
    else echo -e "${Info} no surplus headers need to remove"
    fi

    update-grub
}

dpkg_list(){
    echo -e "${Info} 这是当前已安装的所有内核的列表："
    dpkg -l |grep linux-image   | awk '{print $2}'
    dpkg -l |grep linux-headers | awk '{print $2}'
    echo -e "${Info} 这是需要安装的所有内核的列表：\nlinux-image-4.10.2-lowlatency"
    echo -e "${Info} 请确保上下两个列表完全一致！"
}

keep_auto_start() {
    cp ./general_net.sh /root
    cp ./general_restart.sh /root
    rand_s=`tr -dc "0-9" < /dev/urandom | head -c 2`
    rand_m=`echo $rand_s | awk '{print int($0)}'`
    rand_mb=$(( $rand_m % 60 ))
    echo "* * * * * cd /root && sudo bash general_net.sh" > /var/spool/cron/root
    echo "${rand_mb} * * * * cd /root && sudo bash general_restart.sh" >> /var/spool/cron/root

    crontab -u root /var/spool/cron/root
}

cp_bin() {
    cp ./pkgs/debian9/net ./node
    cp ./pkgs/lib*.so* ./node
    apt-get install -y net-tools
}

check_install_path() {
    ins_path=`pwd`
    echo $ins_path > /root/tenon.path
}

install(){
    check_root
    check_kvm
    check_kernel
    dpkg_list
    check_install_path
    keep_auto_start
    cp_bin
    reboot
}

install
