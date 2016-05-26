#!/bin/bash
#Lab10 Skeleton Script
#Author: Jacob McCrae
#Date Created: July 24, 2014
#This script allows the user to display memory usage, disk usage, or user processes by entering a single character.
#The screen continues to update with the last command selected if there is no user input

#option will be used to store the variable the user selects in the below while loop
option=

#stores the menu that is to be displayed to the user to choose from
menu="\nPress m for memory usage, d for disk usage, p for current user processes, q for quit\n"

#displays menu options to terminal for the first time
echo -e $menu 

#continues while user option is not q
while [ "$option" != "q" ] ; do

	#prompts user for input, stores input in option
	read -t 1 -n 1 -s

	#enters if user entered a character
	if [ -n "$REPLY" ]
	then
		#sets option to what the user entered
		option=$REPLY
	fi

	#implements one of the following 5 options based on user input
	case "$option" in
		m|M) clear ; free -k ; echo -e "$menu" ;;	#displays memory usage and menu
		d|D) clear ; df -h ; echo -e "$menu" ;;		#displays disk usage and menu
		p|P) clear ; ps u ; echo -e " $menu" ;;		#displays current user processes and menu
		q|Q) clear ; break  ;;				#exits the loop
		*) continue					#continues if invalid option
	esac
done

#Tells the shell that this script is done running.
exit 0