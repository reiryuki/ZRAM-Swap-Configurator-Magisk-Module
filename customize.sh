# space
ui_print " "

# var
UID=`id -u`

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

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# cleaning
ui_print "- Cleaning..."
remove_sepolicy_rule
ui_print " "

# zram
PROP=`grep_prop zram.resize $OPTIONALS`
if [ "$PROP" == 0 ]; then
  ui_print "- ZRAM Swap will be disabled"
  ui_print " "
  LMK=false
else
  FILE=/sys/block/zram0/disksize
  ui_print "- Changes $FILE"
  sed -i 's|#o||g' $MODPATH/service.sh
  if echo "$PROP" | grep -q %; then
    ui_print "  to $PROP of RAM size"
    PROP=`echo "$PROP" | sed 's|%||g'`
    sed -i "s|VAR|$PROP|g" $MODPATH/service.sh
    sed -i 's|#%||g' $MODPATH/service.sh
  elif [ "$PROP" ]; then
    ui_print "  to $PROP Byte"
    sed -i "s|ZRAM=3G|ZRAM=$PROP|g" $MODPATH/service.sh
  else
    ui_print "  to 3G Byte"
  fi
  ui_print " "
  PROP=`grep_prop zram.algo $OPTIONALS`
  if [ "$PROP" ]; then
    FILE=/sys/block/zram0/comp_algorithm
    if grep -q "$PROP" $FILE; then
      ui_print "- Changes $FILE"
      ui_print "  to $PROP"
      sed -i "s|#ALGO=|ALGO=$PROP|g" $MODPATH/service.sh
    else
      ui_print "! $PROP is unsupported"
      ui_print "  in $FILE"
    fi
    ui_print " "
  fi
  if [ "`grep_prop zram.lmk $OPTIONALS`" == 0 ]; then
    LMK=false
  else
    LMK=true
  fi
fi

# lmk
if [ $LMK == true ]; then
  sed -i 's|#L||g' $MODPATH/service.sh
else
  ui_print "- Does not use LMK configs"
  ui_print " "
fi












