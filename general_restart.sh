pid=$(pidof net)
kill -9 $pid &
sleep 3
ins_path=`cat /root/tenon.path`
echo $ins_path
cd $ins_path && bash general_start.sh
iptables -F
