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
mount -o ro,remount /system /system;

echo 85 1500000:90 1800000:70 > /sys/devices/system/cpu/cpufreq/interactive/target_loads
echo 20000 1400000:40000 1700000:20000 > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay

echo 2 > /sys/devices/system/cpu/sched_mc_power_savings
