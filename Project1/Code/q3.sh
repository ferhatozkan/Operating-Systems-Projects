#Ferhat Özkan - 150115009
#Onur İzmitlioğlu - 150114012
file="$1"
first="$2"
second="$3" #The three command-line arguments are assigned to file,first and second variables, given the order.
k=0 #Variable k which holds the number of occurrences of the first keyword.
if [ "$file" == "" ] || [ "$first" == "" ] ||  [ "$second" == "" ]; then #Check if the input is valid
   echo "Please enter in format file/word1/word2"
   exit 0 #If not end the scipt
fi

if test ! -f "$file" #If statement to check whether the file exists or not.
then
echo "Error - $file not found.." 	#Print the error.
exit 1
fi


for word in $(<$file) #For loop to find each keyword given by user.
do
if [ "$word" == "$first" ] #If statement check the equality of compared words.
then 
sed -i "s/$2/$3/g" "$file" #Sed command basically changes 2nd variable with the 3rd variable in the file.
let k+=1 #K is incremented by 1 which holds the number of changed words.
fi #End of if statement
done #End of for loop.
echo "All "$k" occurrences of "$first" in "$file" has changed with "$second" " 	#The number of changes made is printed, as well as the initial and final words and the filename that has been worked on.
