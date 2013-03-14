#!/bin/sh

PROG=smqueue
OPENBTS_ENVVARS=/etc/OpenBTS/OpenBTS.conf


SCRIPT=/etc/init.d/$PROG

program_isok() {
    PIDPROG=`pidof $PROG`

    if [ -z "$PIDPROG" ]; then
	echo `date` $PROG is down
    else 
	return 1
    fi
    return 0
}

program_save_event()
{
    #TODO save log files
    if [ -f core ]; then 
	mv core core.$PROG.`hostname`.`date +%s`
    fi

    #Restarting OpenBTS
    $SCRIPT restart
    return 0
}


program_loop_check()
{
    # time to setup all process in OpenBTS
    sleep 15
    echo `date +%s` Monitor started for $PROG
    while true; do
	program_isok
	if [ "$?" -ne "1" ]; then 
	    program_save_event
	    exit 1
	fi
	sleep 1
    done
}

#openbts_isok
program_loop_check
