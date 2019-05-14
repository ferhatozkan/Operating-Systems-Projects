#Ferhat Özkan - 150115009
#Onur İzmitlioğlu - 150114012
filename="$1" #The first command-line input is assigned to filename.
if [ "$filename" == "" ] #Check's if there is a input.
then
echo "Please give a filename as parameter" #Inform the user to give a file name as paramater.
exit 0 #end the script
fi

while read -r line #While loop to check each line of the file
do
number=$line #The number variable holds the number stated in each line.
for i in $(seq 1 $number); #For loop iterates number times 
do printf "*"; #Number times * is printed.
done #End of for loop.
printf "\n" #Used to move cursor to the next line.
done < "$filename" 	#End of while loop. Script has done it’s duty.

