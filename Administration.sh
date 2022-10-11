#!/bin/bash -u
# Administration Program, version 1
# Dongyue Zhang 041033210 zhan0758@algonquinlive.com
#
# This program provides 4 administration funtions:
# 1. listing all users on the machine
# 2. listing all groups
# 3. adding a new user
# 4. creating a welcome message to a user in his/her home directory.
# It will keep running until users choose to quit. 
#
# Using debugging mode
#set -x

# Colors for content printed out
GREEN='\033[00;32m'
RESTORE='\033[0m'

# Prints out a delimiter using shapes.sh
function delimiter() {
	echo
	./shapes.sh l 70 '#'
	echo
}
# Pauses the program until users press Enter key
function pause() {
	delimiter
	read -p "Press [Enter] key to continue..."
	echo
}
# Main method of the program. It provides a menu that executes functions according to users' choices.
function menu() {
	choice=''
	# Loops the menu until users choose to quit.
	while true
	do
	echo "enter your choice:"
	echo "(P)rint out a list of users"
	echo "(L)ist the user groups"
	echo "(A)dd a new user"
	echo "(C)reate a welcome file for a user"
	echo "(Q)uit the menu"
	read choice

	case $choice in
		P|p)
			delimiter
			echo "Actual Users of the System"
			# Filters out users that are not system defined. Then prints out the login names with full names
			awk -F':' '$3 >= 1000 && $3<= 60000 {str = sprintf("%s : %s", $1, $5); print str }' /etc/passwd
			pause
			;;
		L|l) 
			delimiter
			echo "User Group of the System: "
			echo 'An * indicates the group is not a personal group'
			echo
			# Gets all user names on the machine
			users=$(awk -F':' '$3 >= 1000 && $3 <= 60000 {print $1}' /etc/passwd)

			# Filters out group names, then checks if the group names are the same with login name.
			# If it is, then the group is a personal group. If not, it is used for organizing and will be marked with a *.
			awk -F':' '$3 >= 1000 && $3 <= 60000 {print $1}' /etc/group |
			while read group
			do
				if grep -q "$group" <<< "$users";
				then
					echo "$group group"
				else
					echo -e "${GREEN}* ${RESTORE}$group group" # Changes the color of * to green
				fi
			done
			echo	
			pause
			;;
		A|a)
			delimiter
			# Prompts for the login name that users want to create
			read -p "Enter a login name for the user to be added: " newuser
			# Create the user using adduser program
			sudo adduser $newuser
			# Check if the user is created successfully
			if [[ $? ]];
			then
				echo "$newuser is created"
			fi
			pause
			;;
		C|c)
			delimiter
			# Prompts for the login name that users want to send welcome message for
			read -p "Please enter the login name of the user: " login
			# Check if the login name exists. If yes, creates the message under the user's home directory
			if grep $login /etc/passwd > /dev/null;
		       	then
				sudo bash -c  "echo welcome to the system $login > /home/$login/welcome_readme.txt"
				echo "Greeting message created"
			else
				echo "the user doesn't exit"
			fi
			pause
			;;
		Q|q)
			# Quits the program with a successful exit code
			exit 0
			;;
		*)
			# If receives other options not provided above, prints out an error message then starts over the program
			delimiter
			echo "Invalid option. Please choose again"
			pause
			;;
	esac
	done

}
		

delimiter
# Check if the current user has a full name. If not, uses the login name to address the user in the welcome message
user=$(grep $USER /etc/passwd | cut -d ":" -f 5)
if [[ -z "$user" ]]; 
then
	user=$((whoami))
fi
echo "Hello $user"
echo "Welcome to the System Administration menu"
delimiter
# Calls the main method to start the program
menu

