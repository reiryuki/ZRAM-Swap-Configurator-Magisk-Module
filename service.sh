(

MODDIR=${0%/*}

# zram
chmod 0644 /sys/block/zram0/disksize
#1echo 1G > /sys/block/zram0/disksize
#2echo 2G > /sys/block/zram0/disksize
#3echo 3G > /sys/block/zram0/disksize
#4echo 4G > /sys/block/zram0/disksize
#75%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#75%MemTotal=${MemTotalStr:16:8}
#75%let ZRAM="$MemTotal * 3 / 4"
#75%echo $ZRAM\K > /sys/block/zram0/disksize

# wait
sleep 60

# grant
PKG=me.kuder.diskinfo
pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
pm grant $PKG android.permission.ACCESS_MEDIA_LOCATION

) 2>/dev/null


