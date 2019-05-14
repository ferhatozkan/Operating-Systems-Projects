#Ferhat Özkan - 150115009
#Onur İzmitlioğlu - 150114012
number="$1" #First command-line argument, the number to be processed, is assigned to variable number.
length=${#number} #The length of the input is held in the variable length.
firstdigit=${number:0:1} #First digit of number is trimmed.
lastdigit=${number:length-1:1} #Last digit of number is trimmed.
sum=0
temp=0
i=1
sumtemp=0 #Variables are initialized to hold the result and control the loops.

if [ "$number" == "" ] || [ -z "${number##*[!0-9]*}" ] #Check's if there is a input and if the input is a positive number.
then
echo "Please give a positive number as input" #Inform the user to give a file name as paramater.
exit 0 #end the script
fi

if [ $length -eq '1' ] #If statement to check whether the length of input is 1(1-digit input)
then
echo $number #The printed result is the number itself
exit 0 #Exit program.
fi #End of if statement.

sum=$(expr "$sum" + "$firstdigit")
sum=$(expr "$sum" + $(expr "$lastdigit" \* '10'))
nlength=$(expr "$length" - '2') #We know that the first digit will be used in the addition of consecutive 2 numbers for only 1 time(as ones digit), and the last digit will be used in the addition of consecutive 2 numbers for only 1 time(as tens digit),too. So, before we start, we added these values to sum variable.

for i in $(seq 1 $nlength); #For loop to check in-between digits..
do 
temp=${number:i:1} # ..That each are trimmed.. 
sumtemp=$(expr "$temp" \* '11') # ..and multiplied by 11, since they will be used for ones and tens digit at the same time.
sum=$(expr "$sum" + "$sumtemp") #And each value is assigned to sum.
done #End of for loop.
#Now, we have the result of the addition of two consecutive digits obtained from the user.
echo $sum #The result is printed.
