ins_path=`cat /root/tenon.path`
echo $ins_path
echo "prikey="$1 >> $ins_path/node/conf/lego.conf 
