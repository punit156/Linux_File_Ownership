#!/bin/bash

#Checking whether a directory called project already exists or not. If exists,
#then delete it and it's contents.
#Just in case if you want to run multiple test cases, you don't have to go
#through the hassle of deleting the directory every time.
clear

if [ -d "/home/user13-punit/project" ]; then
	rm -r project
fi

#Getting the current user, in order to decide where to generate output file.
current_user=`who | cut -d " " -f 1`
 
#Getting input for script, both from command line or from user.
if [ $# -eq 0 ]; then
	echo "Enter user name or user ID : "
	read USR
	echo "Enter group name or group ID : "
	read GRP
	echo "Enter absolute path : "
	read abs_path
else
	USR=$1
	GRP=$2
	abs_path=$3
fi
#Validating the user 
temp1=`grep -w $USR /etc/passwd | cut -d : -f 1`    #Name
temp2=`grep -w $USR /etc/passwd | cut -d : -f 3`    #ID
if [[ "$temp1" == "$USR" || "$temp2" == "$USR" ]]; then
	echo "User present"
	USR=$temp1
else
	echo "No such user by the name '$USR' in the system. Please enter a valid user-name and try again. Thank you"
	echo ""
	exit 1
fi
#Validating the group
temp3=`getent group $GRP | cut -d : -f 1`    #Group_name
temp4=`getent group $GRP | cut -d : -f 3`    #Group_ID
if [[ "$temp3" == "$GRP" || "$temp4" == "$GRP" ]]; then
	echo "Group present"
	GRP=$temp3
else
	echo "No such group by the name '$GRP' in the system. Please enter a valid group-name and try again. Thank you."
	echo ""
	exit 1
fi
#Checking whether given user is present in the given group
temp5=`cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups | grep "$USR" | grep -w "$GRP"`
if [[ -z "$temp5" ]]; then
	echo "$USR does not belong to group $GRP"
else
	echo "$USR belongs to group $GRP"
fi

#Checking whether the path exists or not
if [ -d "$abs_path" ]; then
	echo "Directory exists at given path"
else
	echo "No such directory in the system. Please enter a valid path and try again. Thank you"
	exit 1
fi

#creating a temp file called content  that stores files from given directory 
#and subdirectories within it.
touch content
ls -Ral $abs_path > content
 
#Creating another temp file from content, that stores only useful content
# Deleting blank lines and lines that are not useful
touch useful
flag=4
while read line
do
	if [[ "$flag" -ne 0 ]]; then
		flag=$flag-1
		continue
	fi
	if [ -z "$line" ]; then
		flag=4
		echo "$line" >> useful
	else
		 echo "$line" >> useful
	fi
done < content

# creating a temp file that stores path names for sub-directories and
# directories
touch path_names
while read line
do 
	if [[ "$line" == /*: ]]; then	
		echo "${line//:}" >> path_names
	fi
done < content

#making the final file that contains everything except for permissions Y/N
touch file_name
touch full_path
touch needed

while read line
do
	echo $line | awk '{print $9}' >> file_name
done < useful

i=1
while read line # from the path_names
do
	count=$i
	while read line1 # from the file_name
	do
		if [[ ! -z $line1 && $count -ne 1 ]]; then
			continue
		elif [[ -z $line1 && $count -ne 1 ]]; then
			count=$count-1
			continue
		elif [[ ! -z $line1 && $count -eq 1 ]]; then
			word=$line"/$line1:" #creating full path
			echo $word >> full_path
		else
			break
		fi
	done < file_name
	i=$i+1
done < path_names

#Joining the first and second column of answer
# Full path name and the permissions
touch modified_useful
while read line
do
	if [[ -z $line ]]; then
		continue
	else
		echo $line >> modified_useful
	fi
done < useful

paste -d "" full_path modified_useful > needed

#Capturing the permissions of files and storing them in an array
touch perms
while read line
do
	echo $line | awk '{print $1}' >> perms
done < modified_useful

IFS=$'\n' read -d '' -r -a perms_arr < /home/user13-punit/perms

#Creating a file with UY or GN or OY etc permissions
touch column_3
i=0
while read line
do
	u=`echo $line | awk '{print $3}'`
	g=`echo $line | awk '{print $4}'`
	if [[ "$u" == "$USR" ]]; then   # U
		if [[ ${perms_arr[$i]:3:1} == "x" ]]; then  #UY
			echo "UY" >> column_3
			i=$i+1
			continue
		else					#UN
			echo "UN" >> column_3
			i=$i+1
			continue
		fi
	fi

	if [[ "$g" == "$GRP" ]]; then   #G
		if [[ ${perms_arr[$i]:6:1} == "x" ]]; then  #GY
			echo "GY" >> column_3
			i=$i+1
			continue
		else						#GN
			echo "GN" >> column_3
			i=$i+1
			continue
		fi
	else
		if [[ ${perms_arr[$i]:9:1} == "x" ]]; then  #OY
			echo "OY" >> column_3
			i=$i+1
			continue
		else						#ON
			echo "ON" >> column_3
			i=$i+1
			continue
		fi
	fi
done < modified_useful

#making the final file
touch final
paste -d ":" needed column_3 > final
mkdir project
cp /home/$current_user/final /home/$current_user/project/executable_files.txt

echo ""
echo "A file called executable_files.txt has been created"
echo "inside project directory. Check it by running the following commands"
echo "on the command line"
echo ""
echo "1) cd project"
echo "2) less executable_files.txt"
echo ""
echo "After doing that if you want to test another cases, just do  cd..   "
echo "and run the script again. You don't have to worry about deleting the"
echo "project directory. It's taken care of."
echo ""
echo "Thank you"
echo ""

#Clean up

function finish {
	rm content
	rm file_name
	rm full_path
	rm path_names
	rm useful
	rm perms
	rm modified_useful
	rm needed
	rm column_3
	rm final
}

trap finish EXIT


