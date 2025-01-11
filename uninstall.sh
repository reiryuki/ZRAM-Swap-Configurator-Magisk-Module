mount -o rw,remount /data
[ ! "$MODPATH" ] && MODPATH=${0%/*}
[ ! "$MODID" ] && MODID=`basename "$MODPATH"`
UID=`id -u`
[ ! "$UID" ] && UID=0

# log
exec 2>/data/adb/$MODID\_uninstall.log
set -x

# run
. $MODPATH/function.sh

# cleaning
remove_sepolicy_rule


