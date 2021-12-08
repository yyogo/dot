
status=`mpris-ctl status`
if [ "$status" = "Playing" ]; then
    mpris-ctl info
elif [ "$status" = "Paused" ]; then
    echo " `mpris-ctl info`"
fi
