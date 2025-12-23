# space
ui_print " "

# var
UID=`id -u`
[ ! "$UID" ] && UID=0

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# recovery
if [ "$BOOTMODE" != true ]; then
  MODPATH_UPDATE=`echo $MODPATH | sed 's|modules/|modules_update/|g'`
  rm -f $MODPATH/update
  rm -rf $MODPATH_UPDATE
fi

# run
. $MODPATH/function.sh

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# cleaning
ui_print "- Cleaning..."
remove_sepolicy_rule
ui_print " "

# free
/system/bin/free
ui_print " "

# disksize
PROP=`grep_prop zram.resize $OPTIONALS`
ZRAM=/block/zram0
FILE=/sys$ZRAM/disksize
FILE2=/sys$ZRAM/comp_algorithm
CUR=`cat $FILE`
CUR2=`cat $FILE2`
ui_print "- Current $FILE = $CUR byte"
ui_print " "
ui_print "- Current $FILE2 = $CUR2"
ui_print " "
if [ "$PROP" == 0 ]; then
  ui_print "- Disables ZRAM Swap"
  ui_print " "
else
  ui_print "- Changes $FILE"
  sed -i 's|#o||g' $MODPATH/service.sh
  if echo "$PROP" | grep -q %; then
    ui_print "  to $PROP of RAM size"
    PROP=`echo "$PROP" | sed 's|%||g'`
    sed -i "s|VAR|$PROP|g" $MODPATH/service.sh
    sed -i 's|#%||g' $MODPATH/service.sh
  elif [ "$PROP" ]; then
    ui_print "  to $PROP byte"
    sed -i "s|DISKSIZE=|DISKSIZE=$PROP|g" $MODPATH/service.sh
  else
    ui_print "  to 3G byte"
    sed -i 's|DISKSIZE=|DISKSIZE=3G|g' $MODPATH/service.sh
  fi
  ui_print " "
  PROP=`grep_prop zram.algo $OPTIONALS`
  if [ "$PROP" ]; then
    if grep -q "$PROP" $FILE2; then
      ui_print "- Changes $FILE2"
      ui_print "  to $PROP"
      sed -i "s|ALGO=|ALGO=$PROP|g" $MODPATH/service.sh
    else
      ui_print "! $PROP is unsupported"
      ui_print "  in $FILE2"
    fi
    ui_print " "
  fi
  PROP=`grep_prop zram.prio $OPTIONALS`
  if [ "$PROP" ]; then
    ui_print "- Sets swap priority $PROP"
    sed -i "s|PRIO=|PRIO=$PROP|g" $MODPATH/service.sh
  else
    ui_print "- Sets swap priority to 0"
    sed -i 's|PRIO=|PRIO=0|g' $MODPATH/service.sh
  fi
  ui_print " "
fi

# swappiness
PROP=`grep_prop zram.swps $OPTIONALS`
if [ "$PROP" ]; then
  if [ "$PROP" -gt 100 ]; then
    PROP=100
  elif [ "$PROP" -lt 0 ]; then
    unset PROP
  fi
fi
FILE=/proc/sys/vm/swappiness
CUR=`cat $FILE`
ui_print "- Current $FILE = $CUR"
ui_print " "
ui_print "- Changes $FILE"
if [ "$PROP" ]; then
  ui_print "  to $PROP"
  sed -i "s|SWPS=|SWPS=$PROP|g" $MODPATH/service.sh
else
  ui_print "  to 100"
  sed -i 's|SWPS=|SWPS=100|g' $MODPATH/service.sh
fi
ui_print " "

# swap_ratio_enable & swap_ratio
PROP=`grep_prop zram.swpre $OPTIONALS`
FILE=/proc/sys/vm/swap_ratio_enable
FILE2=/proc/sys/vm/swap_ratio
CUR=`cat $FILE`
CUR2=`cat $FILE2`
ui_print "- Current $FILE = $CUR"
ui_print " "
ui_print "- Current $FILE2 = $CUR2"
ui_print " "
if [ "$PROP" == 0 ]; then
  ui_print "- Changes $FILE"
  ui_print "  to 0"
  sed -i 's|SWPRE=|SWPRE=0|g' $MODPATH/service.sh
  ui_print " "
elif [ "$PROP" == 1 ]; then
  ui_print "- Changes $FILE"
  ui_print "  to 1"
  sed -i 's|SWPRE=|SWPRE=1|g' $MODPATH/service.sh
  ui_print " "
  PROP=`grep_prop zram.swpr $OPTIONALS`
  if [ "$PROP" ]; then
    if [ "$PROP" -gt 100 ]; then
      PROP=100
    elif [ "$PROP" -lt 0 ]; then
      unset PROP
    fi
  fi
  if [ "$PROP" ]; then
    ui_print "- Changes $FILE2"
    ui_print "  to $PROP"
    sed -i "s|SWPR=|SWPR=$PROP|g" $MODPATH/service.sh
    ui_print " "
  fi
fi

# swap_free_low_percentage
PROP=`grep_prop zram.sflp $OPTIONALS`
if [ "$PROP" ]; then
  if [ "$PROP" -gt 100 ]; then
    PROP=100
  elif [ "$PROP" -lt 0 ]; then
    unset PROP
  fi
fi
CUR=`getprop persist.device_config.lmkd_native.swap_free_low_percentage`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.swap_free_low_percentage`
ui_print "- Current swap_free_low_percentage = $CUR"
ui_print " "
if [ "$PROP" != def ]; then
  ui_print "- Changes swap_free_low_percentage"
  if [ "$PROP" ]; then
    ui_print "  to $PROP"
    sed -i "s|SFLP=|SFLP=$PROP|g" $MODPATH/service.sh
  else
    ui_print "  to 1"
    sed -i 's|SFLP=|SFLP=1|g' $MODPATH/service.sh
  fi
  ui_print " "
fi
if ! grep -q ro.lmk.swap_free_low_percentage /system/bin/lmkd; then
  ui_print "! This ROM does not support"
  ui_print "  swap_free_low_percentage parameter"
  ui_print " "
fi

# swap_util_max
PROP=`grep_prop zram.sum $OPTIONALS`
if [ "$PROP" ]; then
  if [ "$PROP" -gt 100 ]; then
    PROP=100
  elif [ "$PROP" -lt 0 ]; then
    unset PROP
  fi
fi
CUR=`getprop persist.device_config.lmkd_native.swap_util_max`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.swap_util_max`
ui_print "- Current swap_util_max = $CUR"
ui_print " "
if [ "$PROP" != def ]; then
  ui_print "- Changes swap_util_max"
  if [ "$PROP" ]; then
    ui_print "  to $PROP"
    sed -i "s|SUM=|SUM=$PROP|g" $MODPATH/service.sh
  else
    ui_print "  to 99"
    sed -i 's|SUM=|SUM=99|g' $MODPATH/service.sh
  fi
  ui_print " "
fi
if ! grep -q ro.lmk.swap_util_max /system/bin/lmkd; then
  ui_print "! This ROM does not support"
  ui_print "  swap_util_max parameter"
  ui_print " "
fi

# swap_compression_ratio
PROP=`grep_prop zram.scr $OPTIONALS`
if [ "$PROP" ]; then
  if [ "$PROP" -gt 100 ]; then
    PROP=100
  elif [ "$PROP" -lt 0 ]; then
    PROP=0
  fi
fi
CUR=`getprop persist.device_config.lmkd_native.swap_compression_ratio`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.swap_compression_ratio`
ui_print "- Current swap_compression_ratio = $CUR"
ui_print " "
if [ "$PROP" != def ]; then
  ui_print "- Changes swap_compression_ratio"
  if [ "$PROP" ]; then
    ui_print "  to $PROP"
    sed -i "s|SCR=|SCR=$PROP|g" $MODPATH/service.sh
  else
    ui_print "  to 0"
    sed -i 's|SCR=|SCR=0|g' $MODPATH/service.sh
  fi
  ui_print " "
fi
if ! grep -q ro.lmk.swap_compression_ratio /system/bin/lmkd; then
  ui_print "! This ROM does not support"
  ui_print "  swap_compression_ratio parameter"
  ui_print " "
fi




