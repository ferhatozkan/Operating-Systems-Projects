#Ferhat Özkan - 150115009
#Onur İzmitlioğlu - 150114012
while :
  do
     clear
     echo "-------------------------------------"
     echo " Main Menu "
     echo "-------------------------------------"
     echo "[1] Print asterisks"
     echo "[2] Delete files"
     echo "[3] Substitute words"
     echo "[4] Organize directory"
     echo "[5] Print sum of numbers"
     echo "[6] Exit" #Declare all possible options
     echo "======================="
     echo -n "Enter your menu choice [1-6]: " #Ask user for a input
     read yourch
     case $yourch in #switch between cases
        1) read -p 'Filename: ' filename ; ./q1.sh $filename ; echo "Press a key. . ." ; read ;;
 	2) read -p 'Path: ' path ; ./q2.sh $path ; echo "Press a key. . ." ; read ;;
 	3) read -p 'File: ' filename ; read -p 'FirstWord: ' firstword ; read -p 'SecondWord: ' secondword ; ./q3.sh  $filename $firstword $secondword ; echo "Press a key. . ." ; read ;;
 	4) ./q4.sh ; echo "Press a key. . ." ; read ;;
	5) read -p 'Number: ' number ; ./q5.sh $number ; echo "Press a key. . ." ; read ;;
 	6) exit 0 ;;
 	*) echo "Opps!!! Please select choice 1,2,3,4,5 or 6"; #if the input is not valid inform the user.
 	   echo "Press a key. . ." ; read ;;
     esac
  done
