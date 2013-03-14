#!/bin/sh

OPENBTS_ENVVARS=/etc/OpenBTS/OpenBTS.conf
SCRIPT=/etc/init.d/openbts

# Monitoring number of OpenBTS processes
# Socket fd
SOCKET_FILE=$(. $OPENBTS_ENVVARS && echo $SOCKET_FILE)
if [ -z "$SOCKET_FILE" ] ; then
    SOCKET_FILE="/var/run/command"
fi



openbts_isok() {
    PIDOB=`pidof OpenBTS`
    PIDTR=`pidof transceiver`

    if [ -z "$PIDOB$PIDTR" ]; then
        echo `date` OpenBTS and TR are down
    elif [ -z "$PIDOB" ]; then
	echo `date` OpenBTS is down
    elif [ -z "$PIDTR" ]; then
	echo `date` transceiver is down
    else 
	return 1
    fi
    return 0
}

openbts_save_event()
{
    #TODO save log files
    if [ -f core ]; then 
	SUFFIX=`hostname`.`date +%s`
	mv core core.$SUFFIX

	# store databases
	STORE=$PWD
	(
	    cd /var/run
	    for i in  OpenBTS_*.db; do
		echo "Copying $i to $STORE/$i.$SUFFIX"
		cp $i $STORE/$i.$SUFFIX
	    done
	)
	#cd $STORE
	cp OpenBTS      OpenBTS.$SUFFIX
	cp transceiver  transceiver.$SUFFIX
	#clear transaction table
	rm /var/run/OpenBTS_TransactionTable.db
	#
	/etc/init.d/apache2 restart
    fi

    #Restarting OpenBTS
    $SCRIPT restart
    return 0
}


openbts_loop_check()
{
    # time to setup all process in OpenBTS
    sleep 15
    echo `date +%s` Monitor started
    while true; do
	openbts_isok
	if [ "$?" -ne "1" ]; then 
	    openbts_save_event
	    exit 1
	fi
	sleep 1

	chmod 777 $SOCKET_FILE
    done
}

#openbts_isok
openbts_loop_check
