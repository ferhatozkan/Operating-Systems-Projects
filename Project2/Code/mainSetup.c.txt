#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdbool.h>
#include <fcntl.h>
#include <dirent.h>
#include <ctype.h>
#include <assert.h>

//FERHAT OZKAN - 150115009
//MUSTAFA ONUR IZMITLIOGLU - 150114012

#define MAX_LINE 128 /* 128 chars per line, per command, should be enough. */
//-------------File flags for > type operations-------------
#define CREATE_FLAGS (O_WRONLY | O_TRUNC | O_CREAT )
//-------------File flags for >> type files--------------
#define CREATE_APPENDFLAGS (O_WRONLY | O_APPEND | O_CREAT )
//-------------File flags for input files-------------
#define CREATE_INPUTFLAGS (O_RDWR)
//-------------File flags for type mode--------------
#define CREATE_MODE (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)


//-------------Function Prototypes-------------

struct test_struct* create_list(int val, char commandlist[128]);
struct test_struct* add_to_list(int val, char commandlist[128], bool add_to_end);
struct test_struct* search_in_list(int val, struct test_struct **prev);
int delete_from_list(int val);
void print_list(void);
int searchInfile(char *fname, char *str);
void remove_all_chars(char* str, char c);
bool is_valid_int(const char *str);
char** str_split(char* a_str, const char a_delim);
int executebookmark(char *args[], int *background);
int execute(char **args, int *background);
void setup(char inputBuffer[], char *args[],int *background);

//-------------Global variables-------------
  pid_t childpid; //childpid
  int counter = 0;
  int background;
  int backchildnumber = 0;
//-------------struct for the link list-------------
struct test_struct
  {
  int val;
  char commandlist[128];
  struct test_struct *next;
  };

//-------------Initialize list of strings for bookmark operation-------------
struct test_struct *head = NULL;
struct test_struct *curr = NULL;

//-------------Function that creates a new list if there is no list of strings-------------
struct test_struct* create_list(int val, char commandlist[128])
  {
  struct test_struct *ptr = (struct test_struct*)malloc(sizeof(struct test_struct));
  if(NULL == ptr)
    {
    fprintf(stderr,"\n Node creation failed \n");
    return NULL;
    }
  ptr->val = val;
  strcpy(ptr->commandlist , commandlist);
  ptr->next = NULL;

  head = curr = ptr;
  return ptr;
  }

//-------------Function that adds a new string to the bookmark string list-------------
struct test_struct* add_to_list(int val, char commandlist[128], bool add_to_end)
  {
    if(NULL == head)
      {
      return (create_list(val,commandlist));
      }


    struct test_struct *ptr = (struct test_struct*)malloc(sizeof(struct test_struct));
    if(NULL == ptr)
      {
      fprintf(stderr,"\n Node creation failed \n");
      return NULL;
      }
    ptr->val = val;
    strcpy(ptr->commandlist , commandlist);
    ptr->next = NULL;

    if(add_to_end)
      {
      curr->next = ptr;
      curr = ptr;
      }
    else
      {
      ptr->next = head;
      head = ptr;
      }
    return ptr;
  }

//-------------Function that searches the index in string list for delete operation-------------
struct test_struct* search_in_list(int val, struct test_struct **prev)
  {
  struct test_struct *ptr = head;
  struct test_struct *tmp = NULL;
  bool found = false;

  //printf("\n Searching the list for value [%d] \n",val);

  while(ptr != NULL)
    {
    if(ptr->val == val)
      {
      found = true;
      break;
      }
    else
      {
      tmp = ptr;
      ptr = ptr->next;
      }
    }

  if(true == found)
    {
    if(prev)
        *prev = tmp;
    return ptr;
    }
  else
    {
    return NULL;
    }
  }

//-------------Function for bookmark -d -idx-------------
int delete_from_list(int val)
  {
  struct test_struct *prev = NULL;
  struct test_struct *del = NULL;
  //printf("\n Deleting value [%d] from list\n",val);
  del = search_in_list(val,&prev);

  if(del == NULL)
    {
    return -1;
    }
  else
    {
    if(prev != NULL)
      {
      prev->next = del->next;
      }
    if(del == head)
      {
      head = del->next;
      }
    else if(del == curr)
      {
      curr = prev;
      }
    }
  free(del);
  del = NULL;
  return 0;
  }

//-------------Function for bookmark -l-------------
void print_list(void)
  {
  struct test_struct *ptr = head;
  printf("\n -------Printing list Start------- \n");
  while(ptr != NULL)
    {
    printf("\n [%d] \n",ptr->val);
    printf("\n [%s] \n",ptr->commandlist);
    ptr = ptr->next;
    }
  printf("\n -------Printing list End------- \n");
  return;
  }

//-------------Function for searching string in a file-------------
int searchInfile(char *fname, char *str)
  {
  FILE *fp;
  int line_num = 1;
  int find_result = 0;
  char temp[1024];

  if((fp = fopen(fname, "r")) == NULL)
    {
    return(-1);
    }

  while(fgets(temp, 1024, fp) != NULL)
    {
    if((strstr(temp, strdup(str))) != NULL)
      {
      printf("A match found on line: %d\n", line_num);
      printf("\n%s\n", temp);
      find_result++;
      }
    line_num++;
    }

  if(find_result == 0)
    {
    fprintf(stderr,"\nSorry, couldn't find a match.\n");
    }

  //Close the file if still open.
  if(fp)
    {
    fclose(fp);
    }

  return(0);
  }

//-------------Remove all occourences of a char in a string-------------
void remove_all_chars(char* str, char c)
  {
  char *pr = str, *pw = str;
  while (*pr)
    {
    *pw = *pr++;
    pw += (*pw != c);
    }
  *pw = '\0';
  }

//-------------Check if the input is a valid integer-------------
bool is_valid_int(const char *str)
  {
     // Handle negative numbers.
     //
     if (*str == '-'){
       ++str;
       return false;
     }


     // Handle empty string or just "-".
     //
     if (!*str)
        return false;

     // Check for non-digit chars in the rest of the stirng.
     //
     while (*str)
        {
        if (!isdigit(*str))
           return false;
        else
           ++str;
        }

     return true;
  }

//recursive function for searching in directory and subdirectory
void recursivecodesearch(char * path , char *str)
{

  char *filearray;
  char *directory;
  int i =0;

  DIR * d = opendir(path); // open the path

  if(d==NULL) return; // if was not able return
  struct dirent * dir; // for the directory entries
  while ((dir = readdir(d)) != NULL) // if we were able to read somehting from the directory
    {
      if(dir-> d_type != DT_DIR) {
        filearray = dir->d_name;
        char d_path[255];
        sprintf(d_path, "%s/%s", path, dir->d_name);
        //just check files ending with .c , .C , .h , .H
        if( strstr(filearray,".c") || strstr(filearray,".C") || strstr(filearray,".h") || strstr(filearray,".H"))
          {
           printf("\nSearching in file: %s \n",filearray);
           //search string in file
           if(searchInfile(d_path,str) == -1)
              {
              fprintf(stderr,"COULDNT READ THE FILE !");
              }
          }
      }

      else if(dir -> d_type == DT_DIR && strcmp(dir->d_name,".")!=0 && strcmp(dir->d_name,"..")!=0 ) // if it is a directory
      {
      char d_path[255]; // here I am using sprintf which is safer than strcat
      sprintf(d_path, "%s/%s", path, dir->d_name);
      recursivecodesearch(d_path, str); // recall with the new path
      }
    }
    closedir(d); // finally close the directory
}


//-------------Function to split a string from given delim-------------
char** str_split(char* a_str, const char a_delim)
  {
      char** result    = 0;
      size_t count     = 0;
      char* tmp        = a_str;
      char* last_comma = 0;
      char delim[2];
      delim[0] = a_delim;
      delim[1] = 0;

      /* Count how many elements will be extracted. */
      while (*tmp)
      {
          if (a_delim == *tmp)
          {
              count++;
              last_comma = tmp;
          }
          tmp++;
      }

      /* Add space for trailing token. */
      count += last_comma < (a_str + strlen(a_str) - 1);

      /* Add space for terminating null string so caller
         knows where the list of returned strings ends. */
      count++;

      result = malloc(sizeof(char*) * count);

      if (result)
      {
          size_t idx  = 0;
          char* token = strtok(a_str, delim);

          while (token)
          {
              assert(idx < count);
              *(result + idx++) = strdup(token);
              token = strtok(0, delim);
          }
          assert(idx == count - 1);
          *(result + idx) = 0;
      }

      return result;
  }

void controlBackground()
  {
   backchildnumber--;
  }



extern char **environ;


//-------------Main function-------------
int main()
  {
            char inputBuffer[MAX_LINE]; /*buffer to hold command entered */
            // /* equals 1 if a command is followed by '&' */
            char *args[MAX_LINE/2 + 1]; /*command line arguments */

            struct sigaction childsignal;
            childsignal.sa_handler = controlBackground; /* set up signal handler */
             childsignal.sa_flags = 0;
             if ((sigemptyset(&childsignal.sa_mask) == -1) || (sigaction(SIGCHLD, &childsignal, NULL) == -1))
               {
               fprintf(stderr,"Failed to set handler");
               return 1;
               }

            while (1)
              {
              background = 0;
              printf("myshell: ");
              fflush(NULL); // optimize
              setup(inputBuffer, args, &background);

              if(args[0] == NULL){
                continue;
              }

              if(!strcmp(args[0],"bookmark") && args[1] == NULL )
                {
                fprintf(stderr,"Input is invalid\n");
                continue;
                }

              if(!strcmp(args[0],"bookmark") && !strcmp(args[1],"-i")){

                //Check if input is null
                if (args[2] == NULL)
                  {
                  fprintf(stderr,"Input is invalid enter a integer next to -i\n");
                  continue;
                  }

                //Check if input is not a number
                if(!is_valid_int(args[2]))
                  {
                  fprintf(stderr,"Input is invalid third argument should be an integer\n");
                  continue;
                  }

                executebookmark(args,&background);

              }
              else{
              execute(args,&background);
              }

              }
  }


/* The setup function below will not return any value, but it will just: read
in the next command line; separate it into distinct arguments (using blanks as
delimiters), and set the args array entries to point to the beginning of what
will become null-terminated, C-style strings. */

void setup(char inputBuffer[], char *args[],int *background)
  {
  int length, /* # of characters in the command line */
      i,      /* loop index for accessing inputBuffer array */
      start,  /* index where beginning of next command parameter is */
      ct;     /* index of where to place the next parameter into args[] */

  ct = 0;
  length = -1;
  while(length == -1)
      {
      length = read(STDIN_FILENO,inputBuffer,MAX_LINE);
      }
    /* read what the user enters on the command line */


    /* 0 is the system predefined file descriptor for stdin (standard input),
       which is the user's screen in this case. inputBuffer by itself is the
       same as &inputBuffer[0], i.e. the starting address of where to store
       the command that is read, and length holds the number of characters
       read in. inputBuffer is not a null terminated C-string. */

  start = -1;
  if (length == 0)
    exit(0);

                /* ^d was entered, end of user command stream */

/* the signal interrupted the read system call */
/* if the process is in the read() system call, read returns -1
  However, if this occurs, errno is set to EINTR. We can check this  value
  and disregard the -1 value */
  if ( (length < 0) && (errno != EINTR) )
    {
    perror("error reading the command");
  	exit(-1);           /* terminate with error code of -1 */
    }

	//printf(">>%s<<",inputBuffer);
  for (i=0;i<length;i++)
    { /* examine every character in the inputBuffer */
    switch (inputBuffer[i])
        {
        case ' ':
        case '\t' :               /* argument separators */
        		if(start != -1)
              {
              args[ct] = &inputBuffer[start];    /* set up pointer */
              ct++;
            	}
            inputBuffer[i] = '\0'; /* add a null char; make a C string */
        		start = -1;
        		break;
        case '\n':                 /* should be the final char examined */
        		if (start != -1)
              {
              args[ct] = &inputBuffer[start];
        	    ct++;
        	    }
            inputBuffer[i] = '\0';
            args[ct] = NULL; /* no more arguments to this command */
        		break;

    	  default :             /* some other character */
        		if (start == -1)
        		    start = i;
            if (inputBuffer[i] == '&')
              {
      		    *background  = 1;
              inputBuffer[i-1] = '\0';
		           }
        } /* end of switch */
    }    /* end of for */
    args[ct] = NULL; /* just in case the input line was > 80 */

	  for (i = 0; i <= ct; i++){
      //printf("args %d = %s\n",i,args[i]);
    }
		    
    } /* end of setup routine */





int executebookmark(char *args[], int *background)
  {

    struct test_struct *temp = head;
    //parse string to integer
    int showindex = atoi(args[2]);
    int found = 0;
    char *execstring;

    while(temp != NULL)
      {
      if(temp->val == showindex)
        {
        //search for the index if it is found remove its ""
        execstring = strdup(temp->commandlist);
        remove_all_chars(execstring, '"');
        found = 1;
        }
      temp = temp->next;
      }

    //Check if bookmark with index is found
    if(found==0)
      {
      fprintf(stderr,"Couldnt find a bookmark with index %d\n",showindex);
      return 0;
      }

      //split the bookmark into arg2 string array.
    char **args2 = str_split(execstring,' ');
    char *exargs[128];
    int index =0;
    while(args2[index] != NULL){
      exargs[index] = args2[index];
      index++;
    }
    if( !strcmp(exargs[index-1],"&")  )
      {
      *background = 1;
      }
    else{
      *background = 0;
    }

    exargs[index] = '\0';
    execute(exargs,background);


    return 0;
  }


//-------------FUNCTION TO EXECUTE INPUT ARGS-------------
int execute(char *args[], int *background)
  {
  //Control if the background processes are all closed before execute exit command
  //if they are not closed inform the user and take new command.
  if(backchildnumber > 0 && !strcmp(args[0],"exit"))
    {
    fprintf(stderr,"Im waiting for processes to be executed\n");
    return 0;
    }
  else if(backchildnumber == 0 && !strcmp(args[0],"exit"))
    {
    exit(0);
    }


    //Count how many strings are in args
    int index = 0;
    while(args[index]!=NULL)
      {
      index++;
      }

        //----------------- BOOKMARK -----------------
        if( !strcmp(args[0],"bookmark") )
          {
          //----------------- BOOKMARK -d -----------------
          if(  !strcmp(args[0],"bookmark") &&  !strcmp(args[1],"-d") )
            {

            //Check if input is null
            if (args[2] == NULL)
              {
              printf("Input is invalid enter a integer next to -i\n");
              return 0;
              }

            //Check if input is not a number
            if(!is_valid_int(args[2]))
              {
              printf("Input is invalid third argument should be an integer\n");
              return 0;
              }

            //parse string to integer
            int deleteindex = atoi(args[2]);
            struct test_struct *temp = head;

            //integer to control if the index could be found
            int founddel = 0;

            while(temp != NULL)
              {
              if(temp->val == deleteindex)
                {
                //lookup in list if found delete it
                delete_from_list(deleteindex);
                //counter is to check which index number will given to the next
                //added bookmark
                counter--;
                //check if we have found the index
                founddel = 1;
                break;
                }
              else
                {
                temp =temp->next;
                }
              }

            //If couldnt find indexed bookmark
            if(founddel==0)
              {
              fprintf(stderr,"Couldnt find a bookmark with index %d\n",deleteindex);
              return 0;
              }

            //Now that we have deleted a node we have to update the indexes
            int structcounter = 0;
            //Make temp show the head again
            temp = head;
            while(temp != NULL)
              {
              temp->val = structcounter;
              structcounter++;
              temp = temp->next;
              }
            return 0;
            }



            //----------------- BOOKMARK -l -----------------
            else if(!strcmp(args[0],"bookmark") && !strcmp(args[1],"-l") )
                {

                  struct test_struct *temp = head;

                  //Check for invalid input
                  if (args[2] != NULL)
                    {
                    fprintf(stderr,"Input is invalid\n");
                    return 0;
                    }

                  //Inform user if there is no bookmark in list
                  if (temp == NULL)
                    {
                    fprintf(stderr,"Currently there is no bookmark to list\n");
                    }
                  //print list
                  while(temp != NULL )
                    {
                    printf("%d      ",temp->val);
                    printf("%s\n",temp->commandlist);
                    temp = temp->next;
                    }
                  return 0;
                }




            //----------------- BOOKMARK Adding something new -----------------
            else
              {
              char sbookmark[128];
              strcpy(sbookmark,"");
              for (int i = 0; i < index-1; i++)
                {
                 strcpy(args[i],args[i+1]);
                }

              //Combine right side of bookmark and add spaces also
              //"ls-l" should be written as "ls -l"
              index = index-1;
              for (int i = 0; i < index; i++)
                {
                 strcat(sbookmark,args[i]);
                 if(i!=index-1)
                  {
                  strcat(sbookmark," ");
                  }

                }

              //Organize link list just in case something went wrong
              int structcounter=0;
              struct test_struct *temp = head;
              while(temp != NULL)
                {
                temp->val = structcounter;
                structcounter++;
                temp = temp->next;
                }

              //Add new bookmark to the list
              add_to_list(counter,sbookmark,1);
              //increase linked list counter
              counter++;

              //Organize link list just in case something went wrong
              structcounter=0;
              temp = head;
              while(temp != NULL)
                {
                temp->val = structcounter;
                structcounter++;
                temp = temp->next;
                }
              return 0;
              }

          }

        //----------------- CODESEARCH -----------------
        else if( !strcmp(args[0],"codesearch"))
          {
            //Check if input is valid
            if(args[1]==NULL)
              {
              fprintf(stderr,"Invalid input\n");
              return 0;
              }
           //----------------- RECURSIVE CODESEARCH -----------------
           if ( !strcmp(args[0],"codesearch") && !strcmp(args[1],"-r") )
              {

              //Check if input is valid
              if(args[2]==NULL)
                {
                fprintf(stderr,"Invalid input\n");
                return 0;
                }

                char *args2[128];
                int index =2;
                char searchstring[128];
                strcpy(searchstring,"");
                while(args[index] != NULL){
                  remove_all_chars(args[index],'"');
                  strcat(searchstring,args[index]);
                  strcat(searchstring," ");
                  index++;
                }
              args2[0]= searchstring;


              //printf("%s\n",searchstring);
              char cwd[1024];
              recursivecodesearch(getcwd(cwd, sizeof(cwd)) , searchstring );
              }

           //----------------- NORMAL CODESEARCH -----------------
           else
            {

            char cwd[1024];

            //get the current working directory
            if (getcwd(cwd, sizeof(cwd)) != NULL)
             {
              //fprintf(stdout, "Current working dir: %s\n", cwd);
             }
            //In case the working directory couldnt found
            else
             {
             fprintf(stderr,"getcwd() error");
             }


           char *filearray;
           DIR *dir;
           struct dirent *ent;
           int i =0;


           int index =1;
           char searchstring[128];
           strcpy(searchstring,"");
           while(args[index] != NULL){
             remove_all_chars(args[index],'"');
             strcat(searchstring,args[index]);
             strcat(searchstring," ");
             index++;
           }

           if ((dir = opendir (cwd)) != NULL)
             {
             //search in each dir for the command
             while ((ent = readdir (dir)) != NULL)
               {
               filearray = ent->d_name;
               //just check files ending with .c , .C , .h , .H
               if( strstr(filearray,".c") || strstr(filearray,".C") || strstr(filearray,".h") || strstr(filearray,".H"))
                 {
                  printf("\nSearching in file: %s \n",filearray);
                  //search string in file
                  if(searchInfile(filearray,searchstring) == -1)
                     {
                     fprintf(stderr,"COULDNT READ THE FILE !");
                     }
                 }
               }
             closedir (dir);
             }
           else
             {
             perror ("");
             return EXIT_FAILURE;
             }

           return 0;
            }

          }


       //----------------- PRINT -----------------
       else if( !strcmp(args[0],"print") )
            {
            if(args[1] == NULL)
              {
              int i = 0;
              char *s = *environ;

              for (; s; i++) {
                printf("%s\n", s);
                s = *(environ+i);
              }
                          
              return 0;
              }
            if(args[2] != NULL)
              {
              fprintf(stderr,"Invalid input\n");
              return 0;
              }
            //Get the arg from the environment check if does exist
            remove_all_chars(args[1], '<');
            remove_all_chars(args[1], '>');
            if(getenv(args[1]) == NULL)
              {
              fprintf(stderr,"The variable %s doesnt exists in the environment\n",args[1]);
              return 0;
              }

            printf("The variable %s is: %s\n", args[1] , getenv(args[1]) );
            return 0;
            }

        //----------------- SET -----------------
        else if( !strcmp(args[0],"set") )
          {
          if(args[1] == NULL)
            {
            fprintf(stderr,"Invalid input\n");
            return 0;
            }


          if( strstr(args[1],"=") )
                {
                  if(args[2]!=NULL)
                    {
                    fprintf(stderr,"Invalid input\n");
                    return 0;
                    }

                  char *sstring;
                  sstring = args[1];
                  char **setarr = str_split(sstring,'=');
                  setenv(setarr[0],setarr[1], 1);
                  return 0;
                }

          else if(strcmp(args[2],"=") == 0)
              {
                if(args[4] != NULL)
                  {
                  fprintf(stderr,"Invalid input\n");
                  return 0;
                  }
                setenv(args[1],args[3], 1);
                return 0;
              }


            return 0;

          }


  //----------------- myprog[args] < file.in > file.out -----------------
        else if(!strcmp(args[index-2],">") && !strcmp(args[index-4],"<") )
        {


          childpid = fork();
          backchildnumber++;
          int temp = index;
          if(childpid == -1)
            {
            fprintf(stderr, "Couldn't create a child process \n");
            return 0;
            }

          if(childpid == 0)
              {
              int fd;
              int fd2;
              char foutput[50];
              char finput[50];

              //get file names
              strcpy(finput,args[index-3]);
              strcpy(foutput,args[index-1]);

              //Create two files one used as file.in one as output file with trunc
              fd = open(finput,CREATE_INPUTFLAGS,CREATE_MODE);
              fd2 = open(foutput,CREATE_FLAGS,CREATE_MODE);

              if(fd == -1)
                {
                perror("Failed to open file");
                return 1;
                }

              if(dup2(fd,STDIN_FILENO) == -1){
                perror("Failed to redirect standart output");
                return 1;
              }
              if(close(fd) == -1){
                perror("Failed to close the file");
                return 1;
              }

              if(fd2 == -1){
                perror("Failed to open file");
                return 1;
              }
              if(dup2(fd2,STDOUT_FILENO) == -1){
                perror("Failed to redirect standart output");
                return 1;
              }

              if(close(fd2) == -1){
                perror("Failed to close the file");
                return 1;
              }


              args[temp-1] = args[temp];
              args[temp-2] = args[temp-1];
              args[temp-3] = args[temp-2];
              args[temp-4] = args[temp-3];

              //Initialize a file form dirent (dirent.h library)
              struct dirent *file;
              //Get the ENV PATH's
              char *patharray= getenv("PATH");
              //Seperate from each path from ":"
              patharray = strtok(strdup(patharray),":");

              //Count how many strings are in args
              int index = 0;
              while(args[index]!=NULL)
                  {
                  index++;
                  }
              //----------------------------------

              //Check if there is a & sign and remove it
              //Since this is the case where there is a background processes
              //its obvious that there will be a & sign but I wanted to check anyway.
              //Remove & from args string array
              if(!strcmp(args[index-1],"&"))
                  {
                  args[index-1] = args[index];
                  }

              //While the path is not null.
              while(patharray != NULL)
                  {
                  DIR *dir;
                  //Open the path directory
                  dir = opendir(patharray);
                  //If directory opened succesfully
                  if(dir)
                    {
                      while((file  = readdir(dir) ) != NULL)
                        {
                        //If this file(a command file) is our command file execute it
                        if( strcmp(file->d_name, args[0]) == 0 )
                          {
                          //We have to add a / to the path and add our command
                          strcat(patharray,"/");
                          strcat(patharray,args[0]);
                          //try to execute the command.
                          if (execv(patharray,args) == -1)
                            {
                            fprintf(stderr, "Child process couldn't run \n");
                            }
                          }
                      }
                    }
                  //Skip to the next path if command not found.
                  patharray = strtok(NULL,":");
                  }
              }

            if(childpid>0)
                {
                waitpid(childpid, NULL , 0);
                return 0;
                }


        }

      //----------------- myprog[args] < file.in >> file.out -----------------
      else if(!strcmp(args[index-2],">>") && !strcmp(args[index-4],"<") )
          {


            childpid = fork();
            backchildnumber++;
            int temp = index;
            if(childpid == -1)
              {
              fprintf(stderr, "Couldn't create a child process \n");
              return 0;
              }

            if(childpid == 0)
                {
                int fd;
                int fd2;
                char foutput[50];
                char finput[50];

                strcpy(finput,args[index-3]);
                strcpy(foutput,args[index-1]);

                fd = open(finput,CREATE_INPUTFLAGS,CREATE_MODE);
                fd2 = open(foutput,CREATE_APPENDFLAGS,CREATE_MODE);

                if(fd == -1){
                  perror("Failed to open file");
                  return 1;
                }
                if(dup2(fd,STDIN_FILENO) == -1){
                  perror("Failed to redirect standart output");
                  return 1;
                }
                if(close(fd) == -1){
                  perror("Failed to close the file");
                  return 1;
                }

                if(fd2 == -1){
                  perror("Failed to open file");
                  return 1;
                }
                if(dup2(fd2,STDOUT_FILENO) == -1){
                  perror("Failed to redirect standart output");
                  return 1;
                }

                if(close(fd2) == -1){
                  perror("Failed to close the file");
                  return 1;
                }



                args[temp-1] = args[temp];
                args[temp-2] = args[temp-1];
                args[temp-3] = args[temp-2];
                args[temp-4] = args[temp-3];

                //Initialize a file form dirent (dirent.h library)
                struct dirent *file;
                //Get the ENV PATH's
                char *patharray= getenv("PATH");
                //Seperate from each path from ":"
                patharray = strtok(strdup(patharray),":");

                //Count how many strings are in args
                int index = 0;
                while(args[index]!=NULL)
                    {
                    index++;
                    }
                //----------------------------------

                //Check if there is a & sign and remove it
                //Since this is the case where there is a background processes
                //its obvious that there will be a & sign but I wanted to check anyway.
                //Remove & from args string array
                if(!strcmp(args[index-1],"&"))
                    {
                    args[index-1] = args[index];
                    }

                //While the path is not null.
                while(patharray != NULL)
                    {
                    DIR *dir;
                    //Open the path directory
                    dir = opendir(patharray);
                    //If directory opened succesfully
                    if(dir)
                      {
                        while((file  = readdir(dir) ) != NULL)
                          {
                          //If this file(a command file) is our command file execute it
                          if( strcmp(file->d_name, args[0]) == 0 )
                            {
                            //We have to add a / to the path and add our command
                            strcat(patharray,"/");
                            strcat(patharray,args[0]);
                            //try to execute the command.
                            if (execv(patharray,args) == -1)
                              {
                              fprintf(stderr, "Child process couldn't run \n");
                              }
                            }
                        }
                      }
                    //Skip to the next path if command not found.
                    patharray = strtok(NULL,":");
                    }


                }

              if(childpid>0)
                  {
                  waitpid(childpid, NULL , 0);
                  return 0;
                  }


          }
        //----------------- myprog[args] > file.out -----------------
        else if(!strcmp(args[index-2],">"))
          {


            childpid = fork();
            backchildnumber++;
            int temp = index;
            if(childpid == -1)
              {
              fprintf(stderr, "Couldn't create a child process \n");
              return 0;
              }

            if(childpid == 0)
                {
                int fd;
                char foutput[50];
                strcpy(foutput,args[index-1]);
                fd = open(foutput,CREATE_FLAGS,CREATE_MODE);
                if(fd == -1){
                  perror("Failed to open file");
                  return 1;
                }
                if(dup2(fd,STDOUT_FILENO) == -1){
                  perror("Failed to redirect standart output");
                  return 1;
                }
                if(close(fd) == -1){
                  perror("Failed to close the file");
                  return 1;
                }

                args[temp-1] = args[temp];
                args[temp-2] = args[temp-1];

                //Initialize a file form dirent (dirent.h library)
                struct dirent *file;
                //Get the ENV PATH's
                char *patharray= getenv("PATH");
                //Seperate from each path from ":"
                patharray = strtok(strdup(patharray),":");

                //Count how many strings are in args
                int index = 0;
                while(args[index]!=NULL)
                    {
                    index++;
                    }
                //----------------------------------

                //Check if there is a & sign and remove it
                //Since this is the case where there is a background processes
                //its obvious that there will be a & sign but I wanted to check anyway.
                //Remove & from args string array
                if(!strcmp(args[index-1],"&"))
                    {
                    args[index-1] = args[index];
                    }

                //While the path is not null.
                while(patharray != NULL)
                    {
                    DIR *dir;
                    //Open the path directory
                    dir = opendir(patharray);
                    //If directory opened succesfully
                    if(dir)
                      {
                        while((file  = readdir(dir) ) != NULL)
                          {
                          //If this file(a command file) is our command file execute it
                          if( strcmp(file->d_name, args[0]) == 0 )
                            {
                            //We have to add a / to the path and add our command
                            strcat(patharray,"/");
                            strcat(patharray,args[0]);
                            //try to execute the command.
                            if (execv(patharray,args) == -1)
                              {
                              fprintf(stderr, "Child process couldn't run \n");
                              }
                            }
                        }
                      }
                    //Skip to the next path if command not found.
                    patharray = strtok(NULL,":");
                    }

                }
              if(childpid>0)
                {
                waitpid(childpid, NULL , 0);
                return 0;
                }

          }

        //----------------- myprog[args] >> file.out -----------------
        else if(!strcmp(args[index-2],">>"))
          {


            childpid = fork();
            backchildnumber++;
            int temp = index;
            if(childpid == -1)
              {
              fprintf(stderr, "Couldn't create a child process \n");
              return 0;
              }

            if(childpid == 0)
                {
                int fd;
                char foutput[50];
                strcpy(foutput,args[index-1]);
                fd = open(foutput,CREATE_APPENDFLAGS,CREATE_MODE);
                if(fd == -1){
                  perror("Failed to open file");
                  return 1;
                }
                if(dup2(fd,STDOUT_FILENO) == -1){
                  perror("Failed to redirect standart output");
                  return 1;
                }
                if(close(fd) == -1){
                  perror("Failed to close the file");
                  return 1;
                }

                args[temp-1] = args[temp];
                args[temp-2] = args[temp-1];

                //Initialize a file form dirent (dirent.h library)
                struct dirent *file;
                //Get the ENV PATH's
                char *patharray= getenv("PATH");
                //Seperate from each path from ":"
                patharray = strtok(strdup(patharray),":");

                //Count how many strings are in args
                int index = 0;
                while(args[index]!=NULL)
                    {
                    index++;
                    }
                //----------------------------------

                //Check if there is a & sign and remove it
                //Since this is the case where there is a background processes
                //its obvious that there will be a & sign but I wanted to check anyway.
                //Remove & from args string array
                if(!strcmp(args[index-1],"&"))
                    {
                    args[index-1] = args[index];
                    }

                //While the path is not null.
                while(patharray != NULL)
                    {
                    DIR *dir;
                    //Open the path directory
                    dir = opendir(patharray);
                    //If directory opened succesfully
                    if(dir)
                      {
                        while((file  = readdir(dir) ) != NULL)
                          {
                          //If this file(a command file) is our command file execute it
                          if( strcmp(file->d_name, args[0]) == 0 )
                            {
                            //We have to add a / to the path and add our command
                            strcat(patharray,"/");
                            strcat(patharray,args[0]);
                            //try to execute the command.
                            if (execv(patharray,args) == -1)
                              {
                              fprintf(stderr, "Child process couldn't run \n");
                              }
                            }
                        }
                      }
                    //Skip to the next path if command not found.
                    patharray = strtok(NULL,":");
                    }


                }
            if(childpid>0)
            {
            waitpid(childpid, NULL , 0);
            return 0;
            }

          }

        //----------------- myprog[args] < file.in -----------------
        else if(!strcmp(args[index-2],"<"))
        {


          childpid = fork();
          backchildnumber++;
          int temp = index;
          if(childpid == -1)
            {
            fprintf(stderr, "Couldn't create a child process \n");
            return 0;
            }

          if(childpid == 0)
              {
              int fd;
              char finput[50];
              strcpy(finput,args[index-1]);
              fd = open(finput,CREATE_INPUTFLAGS,CREATE_MODE);
              if(fd == -1){
                perror("Failed to open file");
                return 1;
              }
              if(dup2(fd,STDIN_FILENO) == -1){
                perror("Failed to redirect standart output");
                return 1;
              }
              if(close(fd) == -1){
                perror("Failed to close the file");
                return 1;
              }

              args[temp-1] = args[temp];
              args[temp-2] = args[temp-1];

              //Initialize a file form dirent (dirent.h library)
              struct dirent *file;
              //Get the ENV PATH's
              char *patharray= getenv("PATH");
              //Seperate from each path from ":"
              patharray = strtok(strdup(patharray),":");

              //Count how many strings are in args
              int index = 0;
              while(args[index]!=NULL)
                  {
                  index++;
                  }
              //----------------------------------

              //Check if there is a & sign and remove it
              //Since this is the case where there is a background processes
              //its obvious that there will be a & sign but I wanted to check anyway.
              //Remove & from args string array
              if(!strcmp(args[index-1],"&"))
                  {
                  args[index-1] = args[index];
                  }

              //While the path is not null.
              while(patharray != NULL)
                  {
                  DIR *dir;
                  //Open the path directory
                  dir = opendir(patharray);
                  //If directory opened succesfully
                  if(dir)
                    {
                      while((file  = readdir(dir) ) != NULL)
                        {
                        //If this file(a command file) is our command file execute it
                        if( strcmp(file->d_name, args[0]) == 0 )
                          {
                          //We have to add a / to the path and add our command
                          strcat(patharray,"/");
                          strcat(patharray,args[0]);
                          //try to execute the command.
                          if (execv(patharray,args) == -1)
                            {
                            fprintf(stderr, "Child process couldn't run \n");
                            }
                          }
                      }
                    }
                  //Skip to the next path if command not found.
                  patharray = strtok(NULL,":");
                  }
              }
            if(childpid>0)
              {
              waitpid(childpid, NULL , 0);
              return 0;
              }


        }
        //----------------- myprog[args] 2> file.out -----------------
        else if(!strcmp(args[index-2],"2>"))
        {


          childpid = fork();
          backchildnumber++;
          int temp = index;
          if(childpid == -1)
            {
            fprintf(stderr, "Couldn't create a child process \n");
            return 0;
            }

          if(childpid == 0)
              {
              int fd;
              char foutput[50];
              strcpy(foutput,args[index-1]);
              fd = open(foutput,CREATE_FLAGS,CREATE_MODE);
              if(fd == -1){
                perror("Failed to open file");
                return 1;
              }
              if(dup2(fd,STDERR_FILENO) == -1){
                perror("Failed to redirect standart output");
                return 1;
              }
              if(close(fd) == -1){
                perror("Failed to close the file");
                return 1;
              }

              args[temp-1] = args[temp];
              args[temp-2] = args[temp-1];

              //Initialize a file form dirent (dirent.h library)
              struct dirent *file;
              //Get the ENV PATH's
              char *patharray= getenv("PATH");
              //Seperate from each path from ":"
              patharray = strtok(strdup(patharray),":");

              //Count how many strings are in args
              int index = 0;
              while(args[index]!=NULL)
                  {
                  index++;
                  }
              //----------------------------------

              //Check if there is a & sign and remove it
              //Since this is the case where there is a background processes
              //its obvious that there will be a & sign but I wanted to check anyway.
              //Remove & from args string array
              if(!strcmp(args[index-1],"&"))
                  {
                  args[index-1] = args[index];
                  }

              //While the path is not null.
              while(patharray != NULL)
                  {
                  DIR *dir;
                  //Open the path directory
                  dir = opendir(patharray);
                  //If directory opened succesfully
                  if(dir)
                    {
                      while((file  = readdir(dir) ) != NULL)
                        {
                        //If this file(a command file) is our command file execute it
                        if( strcmp(file->d_name, args[0]) == 0 )
                          {
                          //We have to add a / to the path and add our command
                          strcat(patharray,"/");
                          strcat(patharray,args[0]);
                          //try to execute the command.
                          if (execv(patharray,args) == -1)
                            {
                            fprintf(stderr, "Child process couldn't run \n");
                            }
                          }
                      }
                    }
                  //Skip to the next path if command not found.
                  patharray = strtok(NULL,":");
                  }

              }
            if(childpid>0)
                {
                waitpid(childpid, NULL , 0);
                return 0;
                }


        }



      else
        {
        if(*background == 1){
          //Fork the process
          childpid = fork();
          backchildnumber++;

          //Check if the child process couldnt created
          if(childpid == -1)
            {
            fprintf(stderr, "Couldn't create a child process \n");
            return 0;
            }
          //If the process created succesfully
          if(childpid== 0)
            {
            //Initialize a file form dirent (dirent.h library)
            struct dirent *file;
            //Get the ENV PATH's
            char *patharray= getenv("PATH");
            //Seperate from each path from ":"
            patharray = strtok(strdup(patharray),":");

            //Count how many strings are in args
            int index = 0;
            while(args[index]!=NULL)
                {
                index++;
                }
            //----------------------------------

            //Check if there is a & sign and remove it
            //Since this is the case where there is a background processes
            //its obvious that there will be a & sign but I wanted to check anyway.
            //Remove & from args string array
            if(!strcmp(args[index-1],"&"))
                {
                args[index-1] = args[index];
                }

            //While the path is not null.
            while(patharray != NULL)
                {
                DIR *dir;
                //Open the path directory
                dir = opendir(patharray);
                //If directory opened succesfully
                if(dir)
                  {
                    while((file  = readdir(dir) ) != NULL)
                      {
                      //If this file(a command file) is our command file execute it
                      if( strcmp(file->d_name, args[0]) == 0 )
                        {
                        //We have to add a / to the path and add our command
                        strcat(patharray,"/");
                        strcat(patharray,args[0]);
                        //try to execute the command.
                        if (execv(patharray,args) == -1)
                          {
                          fprintf(stderr, "Child process couldn't run \n");
                          }
                        }
                     }
                  }
                //Skip to the next path if command not found.
                patharray = strtok(NULL,":");
                }
              fprintf(stderr,"Command not found\n");

              }

          if(childpid>0)
              {
              return 0;
              }
          }

          else if (*background == 0)
            {
              //Fork the process
              childpid = fork();
              backchildnumber++;

              //Check if the child process couldnt created
              if(childpid == -1)
                {
                fprintf(stderr, "Couldn't create a child process \n");
                return 0;
                }
              //If the process created succesfully
              if(childpid== 0)
                {
                //Initialize a file form dirent (dirent.h library)
                struct dirent *file;
                //Get the ENV PATH's
                char *patharray= getenv("PATH");
                //Seperate from each path from ":"
                patharray = strtok(strdup(patharray),":");

                //Count how many strings are in args
                int index = 0;
                while(args[index]!=NULL)
                    {
                    index++;
                    }
                //----------------------------------

                //Check if there is a & sign and remove it
                //Since this is the case where there is a background processes
                //its obvious that there will be a & sign but I wanted to check anyway.
                //Remove & from args string array
                if(!strcmp(args[index-1],"&"))
                    {
                    args[index-1] = args[index];
                    }

                //While the path is not null.
                while(patharray != NULL)
                    {
                    DIR *dir;
                    //Open the path directory
                    dir = opendir(patharray);
                    //If directory opened succesfully
                    if(dir)
                      {
                        while((file  = readdir(dir) ) != NULL)
                          {
                          //If this file(a command file) is our command file execute it
                          if( strcmp(file->d_name, args[0]) == 0 )
                            {
                            //We have to add a / to the path and add our command
                            strcat(patharray,"/");
                            strcat(patharray,args[0]);

                            //try to execute the command.
                            if (execv(patharray,args) == -1)
                              {
                              fprintf(stderr, "Child process couldn't run \n");
                              }
                            }

                        }
                      }
                    //Skip to the next path if command not found.
                    patharray = strtok(NULL,":");
                    }
                    fprintf(stderr,"Command not found\n");

                }
                if(childpid>0)
                    {
                    waitpid(childpid, NULL , 0);
                    return 0;
                    }
            }
            else{
              return 0;
            }
        }

  }
