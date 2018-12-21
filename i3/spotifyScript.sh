#!/bin/bash
#Grepping out the PID of spotify
spotifyid=$(ps -ef | grep '[/]usr/share/spotify' | awk '{print $2}' | head -1)
wmctrlpath=$(command -v wmctrl)

# Check if wmctrl is installed
if [ -z "$wmctrlpath" ]; then
	echo 'wmctrl not found. Please install it using the appropriate package manager.'
	exit 1;
fi;


#If no PID is found, exit with the warning.
if [ -z "$spotifyid" ]; then
	echo ' ';
	exit 1;
fi;


#Trapping CTRL+C
onexit()
{
	rm -f /tmp/currentsong.txt;
	if [ -e /tmp/currentartist.txt ]; then
		echo 'Deleting artist file!';
		rm -f /tmp/currentartist.txt;
	fi
	echo 'OK, exiting and deleting song file!';
	echo 'Quitting SpotCurrent...';
	exit 1;
}
trap onexit SIGINT;

#User enters prefered mode
case "$1" in
	-t)
		mode=t
	;;
	-tc)
		mode=tc
	;;
	-s)
		mode=s	
	;;
	-help)
		echo "Options:"
		echo "Use -t to seperate artist and song with one line."
		echo "Use -tc to do the same, but the artist gets centered."
		echo "Use -s to sperate artist and song in two files."
		exit 0
	;;
	*)
		mode=normal
esac

#echo $mode

#User enters the desired interval
#echo -n 'Enter your preferred check interval (Press ENTER for default 5 seconds): ';

#read interval;

#if [[ -n ${interval//[0-9]/} ]]; then
#	echo "Contains letters! Exiting..."
#	exit 1;
#fi

#If nothing was read, using the default interval;
#if [ -z "$interval" ]; then
#	interval=5;
#fi
interval=3;

#If another instance is running, exit.
if [ -e /tmp/currentsong.txt ]
	then
		currentsong=$(wmctrl -l -p | grep $spotifyid | sed -n 's/.*'$HOSTNAME'//p');

		if [ "$(echo $currentsong)" == 'Spotify' ]; then
			currentsong=' ';
		fi

		if [ "$(echo $currentsong)" == '' ]; then
			currentsong=' ';
		fi

		echo $currentsong;
			
		#Detects usermode
		case "$mode" in
			t)
	                        split=" - "
        	                artist=${currentsong%%${split}*}
                	        song=${currentsong#*${split}}
                        	echo $artist > /tmp/currentsong.txt
                                echo $song >> /tmp/currentsong.txt
			;;
			tc)
				split=" - "
        	                artist=${currentsong%%${split}*}
                	        song=${currentsong#*${split}}
                        	printf "%40s\n" "$artist - " > /tmp/currentsong.txt
                                printf "%40s\n" "$song" >> /tmp/currentsong.txt
			;;
			s)
				split=" - "
	                        artist=${currentsong%%${split}*}
	                        song=${currentsong#*${split}}
	                        echo $artist > /tmp/currentartist.txt
	                        echo $song > /tmp/currentsong.txt
			;;
			*)
	                        echo -n $currentsong' ' > /tmp/currentsong.txt

		esac
		rm -f /tmp/currentsong.txt
		exit 0;
	else
		#Create the currentsong file
		touch /tmp/currentsong.txt

		#Main loop of the script
		#Get the current song by listing all windows and grepping the matching window with the PID
		currentsong=$(wmctrl -l -p | grep $spotifyid | sed -n 's/.*'$HOSTNAME'//p');

		if [ "$(echo $currentsong)" == 'Spotify' ]; then
			currentsong=' ';
		fi

		if [ "$(echo $currentsong)" == '' ]; then
			currentsong=' ';
		fi

		echo $currentsong;
			
		#Detects usermode
		case "$mode" in
			t)
	                        split=" - "
        	                artist=${currentsong%%${split}*}
                	        song=${currentsong#*${split}}
                        	echo $artist > /tmp/currentsong.txt
                                echo $song >> /tmp/currentsong.txt
			;;
			tc)
				split=" - "
        	                artist=${currentsong%%${split}*}
                	        song=${currentsong#*${split}}
                        	printf "%40s\n" "$artist - " > /tmp/currentsong.txt
                                printf "%40s\n" "$song" >> /tmp/currentsong.txt
			;;
			s)
				split=" - "
	                        artist=${currentsong%%${split}*}
	                        song=${currentsong#*${split}}
	                        echo $artist > /tmp/currentartist.txt
	                        echo $song > /tmp/currentsong.txt
			;;
			*)
	                        echo -n $currentsong' ' > /tmp/currentsong.txt

		esac
		rm -f /tmp/currentsong.txt
		exit 0;
fi
