#Ferhat Özkan - 150115009
#Onur İzmitlioğlu - 150114012
mkdir -p largest
mkdir -p smallest
#Two directories are initialized which will hold the smallest and the largest file in the current path.
path=$(pwd) #Current path is assigned to path variable.
largestfile=$(find . -maxdepth 1 -type f ! -iname "*.sh" -printf '%s %p\n'| sort -nr | head -1) #Command that finds and prints the largest file in the directory,with its size. Maxdepth 1 such that the find command will only search in current directory
smallestfile=$(find . -maxdepth 1 -type f ! -iname "*.sh" -printf '%s %p\n'| sort -nr | tail -1) #Command that finds and prints the smallest file in the directory, with its size.Maxdepth 1 such that the find command will only search in current directory
largestfname="${largestfile##*/}"
smallestfname="${smallestfile##*/}" #The name of each file,largestfile and smallestfile, is assigned to the largestfname and smallestfname, with given order.

mv $path/$largestfname $path/largest
mv $path/$smallestfname $path/smallest #Each file, largest and the smallest, are moved to the directories which we initialized on top of the script.

echo "$largestfname is moved to the directory largest " 
echo "$smallestfname is moved to the directory smallest " #The files and their new directories are printed.


