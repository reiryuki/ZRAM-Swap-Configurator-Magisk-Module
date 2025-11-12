# free
/system/bin/free
echo " "

# disksize
ZRAM=/block/zram0
FILE=/sys$ZRAM/disksize
FILE2=/sys$ZRAM/comp_algorithm
CUR=`cat $FILE`
CUR2=`cat $FILE2`
echo "- $FILE = $CUR byte"
echo " "
echo "- $FILE2 = $CUR2"
echo " "

# swappiness
FILE=/proc/sys/vm/swappiness
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "

# swap_ratio_enable
FILE=/proc/sys/vm/swap_ratio_enable
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "

# swap_ratio
FILE=/proc/sys/vm/swap_ratio
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "

# swap_free_low_percentage
CUR=`getprop persist.device_config.lmkd_native.swap_free_low_percentage`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.swap_free_low_percentage`
echo "- swap_free_low_percentage = $CUR"
echo " "

# swap_util_max
CUR=`getprop persist.device_config.lmkd_native.swap_util_max`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.swap_util_max`
echo "- swap_util_max = $CUR"
echo " "









