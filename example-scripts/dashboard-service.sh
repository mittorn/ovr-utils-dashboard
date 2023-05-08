#!/bin/sh
VR_ROOT=/path/to/steamvr
OVR_UTILS_ROOT=./..
unset SteamAppId
unset SteamGameId
#env > /home/mittorn/dashboard-env.txt
unset LD_LIBRARY_PATH
unset LIBGL_DRIVERS_PATH
unset LIBGL_ALWAYS_SOFTWARE
wait_for_system_button()
{
stdbuf -oL $VR_ROOT/bin/linux64/vrcmd --showevents |grep -m 1 --line-buffered 'VREvent_ButtonPress from 1 k_EButton_System'|while read line; do echo "$line";killall $VR_ROOT/bin/linux64/vrcmd;done
}
while pidof vrserver && wait_for_system_button
do
$OVR_UTILS_ROOT/builds/linux/ovr-utils.x86_64 --no-window --disable-delta-smoothing
done