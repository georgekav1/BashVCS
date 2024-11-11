#!/bin/bash

while true; do                                                          #While loop to bring user back to menu after each procedure has been run
    clear
    echo "Menu driven Version Control System"                           #Format of menu with several options
    echo ""
    echo "1. Create repository"
    echo "2. Add file to a repository"
    echo "3. Display log options"
    echo "4. Check Out File"
    echo "5. Check In File"
    echo "6. View change notes"
    echo "7. Delete file"
    echo "8. Exit"

    read -p "Enter your choice (1-8): " choice                           #Invites the user to enter a number to run a procedure

    case $choice in                                                      #Will run a section of code corresponding to the option picked above

        1)
            # Create a repository
            read -p "Please enter new repository name:" newRepo          #Assigns value entered by user to variable newRepo
            mkdir "$newRepo"                                             #Creates a directory with name read in from user
            if [ -d "$newRepo" ]                                         #Checking to see if directory was created
            then    
                echo "Repository created."
            else
                echo "Repository creation unsuccessful."
            fi
            now="$(date)"                                                #Command substitution to display current date and time
            echo "$newRepo" created - "$now" >> "log.txt"                #Adds details to log.txt 
            read -p "Press Enter to continue."                           #Takes user back to menu
            ;;

        2)
            # Add file to the repository
            PS3="Select repository to store new file:"
            select dir in *
            do 
                if [ -d "$dir" ]           
                then 
                    cd $dir
                    read -p "Please enter new file name:" newFile
                    touch "$newFile"
                    if [ -f "$newFile" ]                                     #Creates file and checks to see if it is created
                    then
                        echo "File created and stored in new directory."
                        cd "$OLDPWD"
                        now="$(date)"                                        #Command substitution to display current date and time
                        echo "$newFile" created - "$now" >> "log.txt"        #Adds details to log.txt 
                    else
                        echo "File could not be created or stored."
                    fi
                    break
                else
                    echo "Repository does not exist."
                    break
                fi
            done
            
            read -p "Press Enter to continue."                               #Takes user back to menu

            ;;

        3) 
            # Display the log
            echo "Log Options"                                               #Displays several options for user to choose from
            echo ""
            echo "1.View log"
            echo "2.Search by date"
            echo "3.Search by file"
            echo "4.Search by user"
            read -p "Enter desired option (1-4): " option                    #Invites user to select which procedure to run

            case $option in 
                1)
                    less log.txt                                             #Displays log
                    ;;
                2)
                    read -p "What date do you wish to search for: " date     #Searches log for specific date
                    grep "$date" log.txt
                    ;;
                3)
                    read -p "What file do you wish to search for: " file     #Searches log for specific file
                    grep "$file" log.txt
                    ;;
                4)
                    read -p "What user do you wish to search for: " user     #Searches log for specific user ID
                    grep "$user" log.txt
                    ;;
                *) 
                    echo "Invalid choice."                                   #Legislates for incorrect user input
                    ;;
            esac
            read -p "Press Enter to continue."                               #Takes user back to menu
            ;;

        4)
            # Check Out a File
            PS3="Please select directory from options above:"                       #Displays list of numbered directories above 
            select dir in *                                                         #Shows all directories in working directory
            do
            if [ -d "$dir" ]                                                        #Check if directory exists before next iteration of loop
                then    
                    cd $dir                                                         #Move into chosen directory

                    PS3="Please select file from options above:"
                    select file in *                                                #Shows all files in the current directory
                    do 
                        if grep -Fxq "$file" checkout.txt                           #Checks if selected file is free to checkout
                        then
                            echo "Error file is already checked out."               #Error message which takes user back to main menu
                            break
                        else 
                            nano "$file"                                            #Opens up chosen file in nano text editor
                            now="$(date)"                                           #Command substitution to display current date and time
                            user="$(id -u)"                                         #Gets the user id 
                            cd "$OLDPWD"                                            #Navigates back to previous repository
                            echo "$file" accessed - "$now" by "$user" >> "log.txt"  #Adds log details to log.txt
                            echo "$file" >> "checkout.txt"                          #Adds the file to the checkout.txt
                            echo "File has been checked out"
                            break
                        fi
                        done 
                    break
            else
                echo "Repository does not exist."                                   #Error message if directory is not selected
                break
            fi
            done

            read -p "Press Enter to continue."                                      #Takes user back to menu
            ;;

        5)  #Check in a file
            details=$(cat checkout.txt)
            PS3="Please select file you wish to checkin: "
            select file in $details
            do 
                now="$(date)"                                                       #Command substitution to display current date and time
                user="$(id -u)"                                                     #Gets the user id 
                echo $file
                echo "$file" returned - "$now" by "$user" >> "log.txt"              #Adds log details to log.txt
                sed -i "/$file/d" "checkout.txt"                                    #Deletes the file from the checkout.txt. 
                read -p "Do you wish to add a change note? (Y/N) " change           #Gives user the option to add comment
                if [ $change == "Y" ]
                then
                    read -p "Please enter change note: " note
                    echo "$file" "$now" "$user" "$note" >> changeNote.txt           #Adds all listed details to checkout.txt
                    break
                else
                    break
                fi
            done
            read -p "File checked in. Press Enter to continue."                     #Takes user back to menu
            ;;

        6)  #View Change notes file
            read -p "What file do you wish to see the change notes of? " CFile      #Assigns value entered from user to variable CFile
            grep "$CFile" changeNote.txt                                            #Searches for chosen file in changeNote.txt
            read -p "Do you wish to add other criteria e.g user, date? If not, press Enter. " Criteria   #Gives user option to add other values into changeNote.txt
            if [[ -z "$Criteria" ]]                                                 #Checks if chosen criteria exists
            then 
                :
            else  
                grep "$CFile" "$Criteria" changeNote.txt                            #Adds chosen criteria to file in changeNote
            fi
            read -p "Press Enter to continue."                                      #Takes user back to menu
            ;;

        7)  #Delete a file
            echo "Are you sure you wish to delete a file? (Y/N)"                    #Gives user option to cancel deletion of file
            read check
            if [ $check == "Y" ]            
            then
                PS3="Please select directory from options above:"                   #Displays list of numbered directories above
                select dir in *                                                     #Shows all directories in working directory
                do
                    if [ -d "$dir" ]                                                #Checks if directory exists
                    then 
                        cd "$dir"                                                   #Changes to chosen directory
                        PS3="Please select which file you wish to delete: "         #Displays list of numbered files above
                        select del in *                                             #Shows all files in working directory
                        do 
                            rm $del;                                                #Deletes chosen file
                            cd "$OLDPWD"                                            #Navigates back to previous directory
                            now="$(date)"                                           #Command substitution to display current date and time
                            echo "$del" deleted - "$now" >> "log.txt"               #Adds details to log.txt          
                            break
                        done
                        echo "File deleted."                                        #Success message if file is deleted
                        break
                    else
                        echo "Directory does not exist."                            #Error message if directory is not selected
                    fi
                done
            fi
            read -p "Press Enter to continue."                                      #Takes user back to menu
            ;;

        8)
            # Exit the script
            echo "Goodbye!"
            exit 0
            ;;

        *)
            echo "Invalid choice. Please select a valid option (1-8)."              #Error message when input other than 1-8 has been provided
            read -p "Press Enter to continue."
            ;;
    esac
done

