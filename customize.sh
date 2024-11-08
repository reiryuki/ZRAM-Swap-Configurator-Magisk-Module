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
  sed -i 's|#k||g' $MODPATH/post-fs-data.sh
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# cleaning
ui_print "- Cleaning..."
remove_sepolicy_rule
ui_print " "

# disksize
PROP=`grep_prop zram.resize $OPTIONALS`
ZRAM=/block/zram0
if [ "$PROP" == 0 ]; then
  ui_print "- ZRAM Swap will be disabled"
  ui_print " "
  LMK=false
else
  FILE=/sys$ZRAM/disksize
  ui_print "- Changes $FILE"
  sed -i 's|#o||g' $MODPATH/service.sh
  if echo "$PROP" | grep -q %; then
    ui_print "  to $PROP of RAM size"
    PROP=`echo "$PROP" | sed 's|%||g'`
    sed -i "s|VAR|$PROP|g" $MODPATH/service.sh
    sed -i 's|#%||g' $MODPATH/service.sh
  elif [ "$PROP" ]; then
    ui_print "  to $PROP byte"
    sed -i "s|DISKSIZE=3G|DISKSIZE=$PROP|g" $MODPATH/service.sh
  else
    ui_print "  to 3G byte"
  fi
  ui_print " "
  PROP=`grep_prop zram.algo $OPTIONALS`
  if [ "$PROP" ]; then
    FILE=/sys$ZRAM/comp_algorithm
    if grep -q "$PROP" $FILE; then
      ui_print "- Changes $FILE"
      ui_print "  to $PROP"
      sed -i "s|ALGO=|ALGO=$PROP|g" $MODPATH/service.sh
    else
      ui_print "! $PROP is unsupported"
      ui_print "  in $FILE"
    fi
    ui_print " "
  fi
  PROP=`grep_prop zram.prio $OPTIONALS`
  if [ "$PROP" ]; then
    ui_print "- Sets swap priority $PROP"
    sed -i "s|PRIO=0|PRIO=$PROP|g" $MODPATH/service.sh
  else
    ui_print "- Sets swap priority to 0"
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
if [ "$PROP" ]; then
  ui_print "- Changes $FILE"
  ui_print "  to $PROP"
  sed -i "s|SWPS=100|SWPS=$PROP|g" $MODPATH/service.sh
else
  ui_print "- Changes $FILE"
  ui_print "  to 100"
fi
ui_print " "

# swap_free_low_percentage
PROP=`grep_prop zram.sflp $OPTIONALS`
if [ "$PROP" ]; then
  if [ "$PROP" -gt 100 ]; then
    PROP=100
  elif [ "$PROP" -lt 0 ]; then
    unset PROP
  fi
fi
if [ "$PROP" ]; then
  ui_print "- Changes swap_free_low_percentage"
  ui_print "  to $PROP"
  sed -i "s|SFLP=1|SFLP=$PROP|g" $MODPATH/service.sh
else
  ui_print "- Changes swap_free_low_percentage"
  ui_print "  to 1"
fi
ui_print " "







