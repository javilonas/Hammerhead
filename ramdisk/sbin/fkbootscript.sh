#!/system/bin/sh

# disable sysctl.conf to prevent ROM interference with tunables
# backup and replace PowerHAL with custom build to allow OC/UC to survive screen off
# create and set permissions for /system/etc/init.d if it doesn't already exist
mount -o rw,remount /system /system;
[ -e /system/etc/sysctl.conf ] && mv /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak;
[ -f /system/lib/hw/power.msm8974.so.bak ] || mv /system/lib/hw/power.msm8974.so /system/lib/hw/power.msm8974.so.bak
[ -f /system/bin/thermal-engine-hh-bak ] || mv /system/bin/thermal-engine-hh /system/bin/thermal-engine-hh-bak

if [ ! -e /system/bin/qrngd ]; then
  cp /sbin/qrngd /system/bin/qrngd
  chmod 0666 /system/bin/qrngd
fi;

if [ ! -e /system/bin/qrngp ]; then
  cp /sbin/qrngp /system/bin/qrngp
  chmod 0666 /system/bin/qrngp
fi;

if [ ! -e /system/etc/init.d ]; then
  mkdir /system/etc/init.d
  chown -R root.root /system/etc/init.d;
  chmod -R 755 /system/etc/init.d;
fi;

# Iniciar SQlite
/res/ext/sqlite.sh

# Iniciar Zipalign
/res/ext/zipalign.sh

# Iniciar Tweaks Lonas_KL
/res/ext/tweaks.sh

mount -o ro,remount /system /system;
