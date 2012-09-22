#
# Regular cron jobs for the salor-hospitality package
#
0 4	* * *	root	[ -x /usr/bin/salor-hospitality_maintenance ] && /usr/bin/salor-hospitality_maintenance
