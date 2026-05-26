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
if ! grep -q ro.lmk.swap_free_low_percentage /system/bin/lmkd; then
  echo "! This ROM does not support"
  echo "  swap_free_low_percentage parameter"
  echo " "
fi

# swap_util_max
CUR=`getprop persist.device_config.lmkd_native.swap_util_max`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.swap_util_max`
echo "- swap_util_max = $CUR"
echo " "
if ! grep -q ro.lmk.swap_util_max /system/bin/lmkd; then
  echo "! This ROM does not support"
  echo "  swap_util_max parameter"
  echo " "
fi

# swap_compression_ratio
CUR=`getprop persist.device_config.lmkd_native.swap_compression_ratio`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.swap_compression_ratio`
echo "- swap_compression_ratio = $CUR"
echo " "
if ! grep -q ro.lmk.swap_compression_ratio /system/bin/lmkd; then
  echo "! This ROM does not support"
  echo "  swap_compression_ratio parameter"
  echo " "
fi

# min_free_kbytes
FILE=/proc/sys/vm/min_free_kbytes
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "

# extra_free_kbytes
FILE=/proc/sys/vm/extra_free_kbytes
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "







