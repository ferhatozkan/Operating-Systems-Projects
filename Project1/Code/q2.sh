#Ferhat Özkan - 150115009
#Onur İzmitlioğlu - 150114012
path="$1" 	#The first command-line argument is assigned to the variable path.
if [ "$path" == "" ] #If the input is not assigned by user;..
then
path=$(pwd) #Then the working directory is assigned to path.
fi
if [ ! -d "$path" ]; then #Check the given path 
  echo "Given path doesnt exists" #If it doesnt exist inform the user.
  exit 0 #End the script
fi
echo "$path" #Print the path.
cd $path #Current directory becomes the path.
rm -f -i {*.c,*.h,makefile,Makefile} #The files named makefile and Makefile and all files which end with .c and .h are removed.


