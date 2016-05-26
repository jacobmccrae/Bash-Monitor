#!/bin/bash
#Lab10 bettermon Script
#Author: Jacob McCrae
#Date Created: July 30, 2014
#This script is the better resource monitor that displays a top banner, bar graphs, and top active processes
#Top Banner output: current time, current cpu usage, current free memory and total memory
#Bar graphs output: over 25s, cpu usage, memory usage, and disk usage for all disks on the system
#Bar graphs also use colours to indicate low(green), medium(yellow), and high(red) usage

#sets the initial screen for the program
function setScreen (){
	#resets any initial tput, sets the background to black, sets the text to white
	tput reset ; tput setb 7 ; tput setf 0
	clear	#clears the screen of any previous output
}

#retrieves either the percentage of the current cpu usage or current memory usage
function totalUsage (){
	#retrieves the total  cpu usage and memory usage and stores the values in usage; delimited by a comma
	usage=`ps --no-headers -axu | awk '{cpu+=$3; mem+=$4} END{printf "%d,%d", cpu, mem}'`

	case "$1" in
		c) cpu=`echo $usage | cut -d"," -f1` ;;	#stores the cpu value cut from usage in field 1
		m) mem=`echo $usage | cut -d"," -f2`	#stores the memory value cut from usage in field 1
	esac
}

#retrieves the percentage of the current disk usage
function getDiskUse (){
	#stores the string of the percentage taken from the Used column in the output of df, ex. 50%
	dUper=`df --total | grep "total" | xargs | cut -d" " -f5`

	#stores the string length of dUper, length is either 2,3,or4
	#dLen=4 - ex. dUper=100%
	#dLen=3	- ex. dUper=50%
	#dLen=2 - ex. dUper=5%
	dLen=${#dUper} 

	i=2 			#initializes i to 2 for the while loop	
	columns="1"		#columns is used to determine the number of columns to be cut from dUper based on dLen

	#determines how many columns will be cut for cut command in dUsage variable below
	while [ $i -lt $dLen ]
	do
		columns="$columns,$i"	#appends i to end of columns
		i=$[ $i+1 ]				#increments i by 1
	done

	#stores only the number of the percentage from the string dUper
	#uses columns to determine which columns to cut from dUper
	dUsage=`echo $dUper | cut -c$columns`

}

#initializes the graphs used for cpu usage, memory usage, and disk usage to no usage(.)
function initGraphs (){
	#cpu usage graph stored in arrays c1 to c5
	#changes . to * if 100% usage
	c5=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 76%-99% usage
	c4=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 51%-75% usage
	c3=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 26%-50% usage
	c2=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 1%-25% usage
	c1=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	

	#memory usage graph stored in arrays m1 to m5
	#changes . to * if 100% usage
	m5=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 76%-99% usage
	m4=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 51%-75% usage
	m3=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 26%-50% usage
	m2=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 1%-25% usage
	m1=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	

	#disk usage graph stored in arrays d1 to d5
	#changes . to * if 100% usage
	d5=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 76%-99% usage
	d4=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 51%-75% usage
	d3=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 26%-50% usage
	d2=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
	#changes . to * if 1%-25% usage
	d1=( "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." "." )	
}

#displays the banner in the top of the screen
function topBanner (){
	#makes the cursor invisible and places it at the top left corner
	tput civis ; tput cup 0 0 

	#outputs the current time and the current cpu usage in percentage
	totalUsage "c"
	echo -e "`date +"%-l:%M %p"` CPU: $cpu%\c"

	#outputs the current memory usage, total memory and free memory
	free -k | awk 'NR==2 {printf " MEM: %d total, %d free", $2, $4}'

	#removes any extra characters from the end of the line	
	if [[ $cpu -lt 10 ]]	#removes from column 48 to end of line
	then
		tput cup 0 48 
	elif [[ $cpu -lt 100 ]]	#removes from column 49 to end of line
	then
		tput cup 0 49
	else			#removes from column 50 to end of line
		tput cup 0 50
	fi
	tput el	#from cursor position to end of line
}

#turns on or off the cpu usage, memory usage, or disk usage graph
#	by setting ctoggle, mtoggle, or dtoggle to 0(off) or 1(on)
function toggleOpt (){
	#cpu usage graph, memory usage, or disk usage graph is off
	if [ $1 -eq 0 ]
	then
		case "$2" in
			c) ctoggle=1 ;;	#turns on cpu usage graph
			m) mtoggle=1 ;;	#turns on memory usage graph
			d) dtoggle=1	#turns on disk usage graph
		esac
	else	#cpu usage graph, memory usage, or disk usage graph is on
		case "$2" in
			c) ctoggle=0 ;;	#turns off cpu usage graph
			m) mtoggle=0 ;;	#turns off memory usage graph
			d) dtoggle=0 	#turns off disk usage graph
		esac
	fi
	tput cup 1 0 ; tput ed	#sets the cursor to row 1, column 0 and erases the rest of the screen
}

#updates and outputs the cpu usage graph
#outputs the cpu usage graph if the cpu toggle is on(1)
#returns if the cpu toggle is off(0)
function cpuGraph (){
	updateGraph $cpu "c"	#invokes updateGraph to update the cpu usage graph

	#returns of ctoggle is 0
	if [ $ctoggle -eq 0 ]
	then
		return
	fi

	tput cup 2 0			#position of cpu usage graph if turned on

	#outputs the cpu usage graph using the here document
	cat <<-cpuEOH
		CPU Usage

		${c5[@]}
		${c4[@]}
		${c3[@]}
		${c2[@]}
		${c1[@]}

	cpuEOH
}

#updates and outputs the memory usage graph
#outputs the memory usage graph if the memory toggle is on(1)
#returns if the memory toggle is off(0)
function memGraph(){
	totalUsage "m"				#invokes totalUsage to initialize mem usage variable
	updateGraph $mem "m"		#invokes updateGraph to update the memory usage graph

	#determines where to place the cursor to draw memory usage graph
	if [ $mtoggle -eq 0 ]		#returns if memory usage graph is off
	then
		return
	elif [[ $ctoggle -eq 0 ]] 	#enters if cpu usage graph off
	then
		tput cup 2 0 			#position of memory usage graph if cpu usage graph off
	else
		tput cup 10 0 			#position of memory usage graph if cpu usage graph on
	fi
	
	#outputs the cpu usage graph using the here document
	cat <<-memEOH
		Memory Usage

		${m5[@]}
		${m4[@]}
		${m3[@]}
		${m2[@]}
		${m1[@]}

	memEOH
}

#updates and outputs the disk usage graph
#outputs the disk usage graph if the disk toggle is on(1)
#returns if the disk toggle is off(0)
function diskGraph(){
	getDiskUse				#invokes getDiskUse to initialize the value of dUsage
	updateGraph $dUsage "d"	#invokes updateGraph to update the disk usage graph for the current second

	#determines where to place the cursor to draw disk usage graph
	if [ $dtoggle -eq 0 ]	#returns if disk usage graph is off
	then
		return
	elif [[ $ctoggle -eq 0 && $mtoggle -eq 0 ]] 	#cpu usage graph and memory usage graphs are off
	then		
		tput cup 2 0 		#only disk usage graph on
	elif [[ $ctoggle -eq 1 || $mtoggle -eq 1 ]]		#either cpu usage graph or memory usage graph is on
	then
		if [[ $ctoggle -eq 0 || $mtoggle -eq 0 ]]	#either cpu usage graph or memory usage graph is off
		then
			tput cup 10 0	#only 2 graphs on
		fi
	elif [[ $ctoggle -eq 1 && $mtoggle -eq 1 ]] 	#cpu usage graph and memory usage graph on
	then
		tput cup 18 0 		#all graphs on
	fi
	
	#outputs the disk usage graph using the here document
	cat <<-diskEOH
		Disk Usage

		${d5[@]}
		${d4[@]}
		${d3[@]}
		${d2[@]}
		${d1[@]}

	diskEOH
}

#updates any usage graph
#input: arg $1 is the percentage usage for the specified graph
#		arg $2 specifies the graph it is updating (c, m, d)
function updateGraph (){
	graphLines $1		#invokes the graphLines function, passes the first parameter to this function as an argument
	graphBar			#invokes the graphBar function to retrieve the bar of the graph for the calling function

	#sets the lines of the graph based on the second parameter passed by the calling function
	if [ "$2" = "c" ] 	#calling function is cpuGraph
	then	
		#sets the cpu usage graph to the elements in bar
		c5[$seconds]=${bar[4]}
		c4[$seconds]=${bar[3]}
		c3[$seconds]=${bar[2]}
		c2[$seconds]=${bar[1]}
		c1[$seconds]=${bar[0]}
	elif [ "$2" = "m" ] #calling function is memGraph
	then
		#sets the memory usage graph to the elements in bar
		m5[$seconds]=${bar[4]}
		m4[$seconds]=${bar[3]}
		m3[$seconds]=${bar[2]}
		m2[$seconds]=${bar[1]}
		m1[$seconds]=${bar[0]}
	else #calling function is diskGraph
		#sets the disk usage graph to the elements in bar
		d5[$seconds]=${bar[4]}
		d4[$seconds]=${bar[3]}
		d3[$seconds]=${bar[2]}
		d2[$seconds]=${bar[1]}
		d1[$seconds]=${bar[0]}
	fi
}

#sets lines to a number between 0 and 5 based on arg $1 passed to the script
#arg $1 is either cpu usage, memory usage, or disk usage
function graphLines (){
	#determines the number of lines of the graph that will contain a star (*)
	if [[ $1 -eq 0 ]]					#enters if no usage
	then
		lines=0
	elif [[ $1 -ge 1 && $1 -lt 25 ]]	#enters if usage is between 1% and 25%
	then
		lines=1
	elif [[ $1 -ge 25 && $1 -lt 50 ]]	#enters if usage is between 26% and 50%
	then
		lines=2
	elif [[ $1 -ge 50 && $1 -lt 75 ]]	#enters if usage is between 51% and 75%
	then
		lines=3
	elif [[ $1 -ge 75 && $1 -lt 100 ]]	#enters if usage is between 76% and 99%
	then
		lines=4
	elif [[ $1 -ge 100 ]]				#enters if usage is 100%
	then
		lines=5
	fi
}

#sets the bar for the current second (out of 25) for either the cpu usage graph, memory usage graph, or disk usage graph
#lines is used to determine if a star(*) is set as an element in the array bar or if the element remains a dot(.)
function graphBar (){
	#bar is initialized to 5 dots(.) to represent the bar of a specified graph
	bar=( "." "." "." "." "." )
	
	i=0		#i is used in the while loop

	#lines=5 - all dots replaced with stars 		lines=2 - first 2 dots replaced with stars
	#lines=4 - first 4 dots replaced with stars		lines=1 - first dot replaced with a star
	#lines=3 - first 3 dots replaced with stars		lines=0 - no dots are replaced
	#continues until i is equal to lines, lines is at most 5 and at least 0
	while [ $i -lt $lines ]
	do
		#sets the elements of bar to *
		if [[ $i -le 1 ]]
		then
			#sets the foreground colour to green on graph lines 1 and 2 (low usage)
			bar[$i]="`tput setf 2`*`tput setf 0`"	
		elif [[ $i -eq 2 || $i -eq 3 ]]
		then
			#sets the foreground colour to yellow on graph lines 3 and 4 (medium usage)
			bar[$i]="`tput setf 6`*`tput setf 0`"	
		else
			#sets foreground colour to red on graph line 5 (high usage)
			bar[$i]="`tput setf 4`*`tput setf 0`"	
		fi
		
		i=$[ $i+1 ]		#increments the value of i
	done
}

#displays the top 5 active processes
function activeProc (){
	#stores the result of the addition of ctoggle, mtoggle, and dtoggle
	cpos=$[ $ctoggle+$mtoggle+$dtoggle ]

	#decides where to place the cursor to output the active processes
	#dependent on which graphs are turned on or off
	case $cpos in
		0) tput cup 2 0 ;;	#all graphs off
		1) tput cup 10 0 ;;	#only 1 graph on
		2) tput cup 18 0 ;;	#only 2 graphs on
		3) tput cup 26 0	#all graphs on
	esac

	#outputs the top 5 active processes
	cat <<-procEOH
		Most Active Processes

		`ps -eo pid,user,state="STATE",%cpu,%mem,comm --sort -%cpu | head -n6`
		
	procEOH
}

#prompts for user input
function userInput (){
	#outputs the menu for the user to select from
	cat <<-menu
		
		$tdelay second(s) between updates

		Press c to toggle CPU, m to toggle Memory, d to toggle Disk, q to Quit
		Use +/- to increase or decrease time interval

	menu

	#enters if user reduces the time delay to 0 or less
	if [ $tdelay -le 0 ]
	then
		tdelay=1	#sets time delay to 1
	fi

	#prompts user for input
	read -t $tdelay -n 1 -s
}

#displays the resource monitor
function betterMonDisplay (){
	#option will be used to store the variable the user selects in the below while loop
	option=

	#invokes initGraphs function to initialize memory and usage graphs
	initGraphs	

	tdelay=1	#initializes time interval between updates to 1 second

	#stores toggle values for cpu and memory, 0 is off 1 is on, both initialized to toggle on
	ctoggle=1 mtoggle=1 dtoggle=0

	#uses seconds to determine the position of the graphs to be updated
	seconds=0

	#continues while user input is not q
	while [ "$REPLY" != "q" ] ; do
		#invokes the banner function
		topBanner

		#implements one of the following 5 options based on user input
		case "$REPLY" in
			c|C) toggleOpt $ctoggle "c" ;; 	#toggleOpt function to turn on(1) or off(0) cpu usage graph
			m|M) toggleOpt $mtoggle "m" ;; 	#toggleOpt function to turn on(1) or off(0) memory usage graph
			d|D) toggleOpt $dtoggle "d" ;;	#toggleOpt function to turn on(1) or off(0) disk usage graph
			+) tdelay=$[ $tdelay+1 ] ;;		#increments tdelay by 1
			-) tdelay=$[ $tdelay-1 ] ;;		#decrements tdelay by 1 (tdelay will be changed back to 1 if it becomes 0)
			q|Q) clear ; break  ;;			#exits the loop
			*) echo -e "\c"					#dummy option to catch all that doesn't match
		esac

		cpuGraph	#invokes the cpuGraph function to update and output the cpu usage graph if it has been toggled on
		memGraph	#invokes the memGraph function to update and output the memory usage graph if it has been toggled on
		diskGraph	#invokes the diskGraph function to update and output the disk usage graph if it has been toggled on
		activeProc	#invokes the activeProc function to update and output the top 5 processes
		userInput	#invokes the userInput function to retrieve user input

		#enters if seconds is not equal to 24
		if [ $seconds -lt 24 ]
		then
			seconds=$[ $seconds+1 ]	#increments seconds by 1
		else 	
			seconds=0	#sets seconds to 0 if seconds is greater than or equal to 1
		fi
	done
}

#########start program###########

setScreen			#setScreen function to set the screen
betterMonDisplay	#monDisplay function to display the monitor
tput reset			#tput command to reset screen

#Tells the shell that this script is done running.
exit 0