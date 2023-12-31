source ~/mac-zshrc/utilities/colors.sh
source ~/mac-zshrc/utilities/logging.sh
source ~/mac-zshrc/utilities/read-doc.sh -h
source ~/mac-zshrc/iod/helpers.sh
source ~/mac-zshrc/iod/iods.sh

# command documentation
doc=$HOME/mac-zshrc/iod/docs/iod.help

iod() {
    case "$1" in
        .|show)
            cd ~/iod
            log . "IOD main in VS Code" IOD
            code .
            ;;
        go)
            if [ -z "$2" ]; then
                read_doc $doc "NR>=84 && NR<=94"
                return 1
            fi

            module_number="$2"
            student_repo="$4"
            clone_folder=""

            if [ "$module_number" = '-c' ]; then
                echo "${YELLOWBG}Opening Capstone...${RESET}"
                cd ~/iod/labs/Capstone && code .
                return 1
            fi

            attempts=0
            while [ "$attempts" -lt 3 ]; do
                if [ -d ~/iod/labs/module"$module_number" ]; then
                    echo "${INVERTED} Opening Module $module_number... ${RESET}"
                    cd ~/iod/labs/module"$module_number"

                    if [ -n "$(ls -d */ 2>/dev/null)" ]; then
                        echo "Folders inside. Listing them:"
                        ls -al
                        echo -n -e "${BLUEBG} ▶︎ Enter the folder to navigate into:${RESET} "
                        read folder_name

                        attempts_folder=0
                        while [ "$attempts_folder" -lt 2 ]; do
                            if [ -d "$folder_name" ]; then
                                cd "$folder_name"
                                clone_folder="$HOME/iod/labs/module$module_number/$folder_name/$(basename $student_repo .git)"
                                break
                            else
                                echo -e "${RED}Folder \"$folder_name\" doesn't exist${RESET}"
                                echo -n -e "${BLUEBG}  ▶︎ Enter the correct folder name:${RESET} "
                                read folder_name
                                ((attempts_folder++))
                            fi
                        done

                        if [ "$attempts_folder" -eq 2 ]; then
                            echo -e "${RED}⚠️  Too many invalid attempts. Exiting... ↩︎ ${RESET}"
                            return
                        fi
                    fi

                    clone_flag=""
                    clone_helper=""

                    while [ "$#" -gt 0 ]; do
                        case "$1" in
                            --clone|--clone-repo)
                                clone_flag=true
                                shift
                                clone_helper="clone"
                                ;;
                            *)
                                shift
                                ;;
                        esac
                    done

                    if [ -n "$clone_helper" ]; then
                        git clone "$student_repo"  || { echo -e "${RED}Failed to clone repository${RESET}"; return 1 ; }
                        code "$clone_folder"
                        if [ ! -d "$clone_folder" ]; then
                            echo -e "${RED} clone_folder doesn't exist ${RESET}"
                            return 1
                        fi
                        break
                    fi

                    code .

                    return
                else
                    echo "Module \"$module_number\" doesn't exist"
                    check "$module_number"
                    ((attempts++))
                fi
            done
            ;;

        m|module)
            if [ -z "$2" ]; then
                read_doc $doc "NR>=48 && NR<=57"
                return 1
            fi

            module_number="$2"
            module_folder="$HOME/iod/modules/Module $module_number"

             if [ "$module_number" = "-c" ]; then
                loading_bar 0.01
                tput cuu1
                echo -e "${YELLOWBG} Heading to the Capstone folder ${RESET}"

                capstone_folder="$HOME/iod/modules/Capstone"
                cd "$capstone_folder"
                log . "IOD modules" Capstone
                code .
                return 0
            fi

            attempts_module=0
            while [ "$attempts_module" -lt 3 ]; do
                    if [ -d "$module_folder" ]; then
                        loading_bar 0.03
                        tput cuu1
                        echo -e "${GREEN} MODULE Material. loading options ${RESET} "
                        cd "$module_folder" || { echo -e "${RED}Failed to cd to $lab_folder${RESET}"; return 1; }

                        echo -e "${BLUEBG} Contents of the module folder: ${RESET}"
                        echo
                        PS3="${PS3BLUE}Select a subfolder (or press Enter to continue):${PS3RESET}"

                        subfolders=($(find . -maxdepth 1 -type d -exec basename {} \;))
                        num_subfolders=${#subfolders[@]}

                        select subfolder_input in "${subfolders[@]}"; do
                            if [ -z "$subfolder_input" ]; then
                                break
                            fi

                            selected_subfolder="./$subfolder_input"

                            if [ -d "$selected_subfolder" ]; then
                                cd "$selected_subfolder" || { echo -e "${RED}Failed to cd to $selected_subfolder${RESET}"; return 1; }

                                echo -n -e "${BLUE}Choose an option:\n 1. Open in VS Code\n 2. Open in PowerPoint\n 3. Open PDF\n 4. Open Finder\n 5. Cancel\n ${RESET} ${YELLOWBG} ▶︎ Enter the option number:${RESET}"
                                read option

                                case $option in
                                1)
                                    code .
                                    return 0
                                    ;;
                                2)
                                    open ./*.pptx
                                    return 0
                                    ;;
                                3)
                                    pdfs=(*.pdf)
                                    num_pdfs=${#pdfs[@]}

                                    if [ "$num_pdfs" -eq 0 ]; then
                                        echo -e "${YELLOWBG}No PDF files found.${RESET}"
                                    elif [ "$num_pdfs" -eq 1 ]; then
                                        pdf_to_open="${pdfs[1]}"
                                        echo -e "${GREEN}Opening PDF: $pdf_to_open ${RESET}"
                                        echo -e "${NEONGREEN}COMPLETED 〉${RESET}"
                                        open "$pdf_to_open"
                                        return 0
                                    else
                                        echo -e "${BLUEBG}Choose a PDF to open: ${RESET}"

                                        counter=1
                                        for pdf in "${pdfs[@]}"; do
                                            echo " $counter. $pdf"
                                            ((counter++))
                                        done

                                        echo -n -e " Enter the PDF number (or 0 to cancel): "
                                        read -r pdf_option

                                        if [[ "$pdf_option" =~ ^[0-9]+$ ]] && [ "$pdf_option" -gt 0 ] && [ "$pdf_option" -le "$num_pdfs" ]; then
                                            selected_index=$((pdf_option))
                                            pdf_to_open="${pdfs[selected_index]}"
                                            echo -e "${GREEN}Opening PDF: "$pdf_to_open" ${RESET}"
                                            echo -e "${CYAN} COMPLETED  ${RESET}"
                                            open "$pdf_to_open"

                                            return 0

                                        elif [ "$pdf_option" -eq 0 ]; then
                                            echo -e "${YELLOWBG}Canceled. Returning to the subfolder.${RESET}"
                                            return 0
                                        else
                                            echo -e "${RED}Invalid option. Returning to the subfolder.${RESET}"
                                            return 1
                                        fi
                                    fi
                                    ;;
                                4)
                                    open .
                                    return 0
                                    ;;
                                5)
                                    echo -e "${YELLOWBG}Canceled. Returning to the root folder.${RESET}"
                                    return 1
                                    ;;
                                *)
                                    echo -e "${RED}Invalid option. Please try again.${RESET}"
                                    ;;
                                esac

                            else
                                echo -e "${RED}Invalid selection. Please try again.${RESET}"
                            fi
                        done

                        echo -e "${YELLOWBG} No subfolder specified. Opening VS Code in the root folder ${RESET}"
                        code .
                        return 0
                    else
                        echo -e "${RED} module folder not found module: $module_number ${RESET}"
                        if [ "$attempts_module" -eq 2 ]; then
                            echo -e "${RED} ⚠️ Too many invalid attempts. Performing ls instead. ${RESET}"
                            ls "$HOME/iod/modules/Module $module_number"
                            return 1
                        else
                            echo -n -e "  ▶︎ ${BLUEBG} Enter the correct module number: ${RESET}"
                            read module_number
                            module_folder="$HOME/iod/module/Module $module_number"
                            ((attempts_module++))
                        fi
                    fi
            done

            echo -e "${RED} ⚠️ Too many invalid attempts for student name. Returning to home directory. ${RESET}"
            cd ~
            return 1
            ;;

        s|students)
            case "$2" in
                -list)
                    case "$3" in
                        .)
                            printf "%s\n" "${students[@]}"
                            ;;
                        --l)
                            printf "%s\n" "${students_lastname[@]}"
                            ;;
                        --e)
                            printf "%s\n" "${students_email[@]}"
                            ;;
                        --u)
                            printf "%s\n" "${students_usernames[@]}"
                            ;;
                        --all|--a)
                            echo -e "${YELLOW}Name\tLast Name\t\tEmail\t\t\tUsername${RESET}"

                            echo -e "${YELLOWBG}                                                                                     ${RESET}"
                            for ((i = 0; i < ${#students[@]}; i++)); do
                                echo "${students[$i]}\t${students_lastname[$i]}\t${students_email[$i]}\t\t${students_usernames[$i]}"
                            done
                             echo -e "${YELLOWBG}                                                                                     ${RESET}"
                            ;;
                        *)
                            read_doc $doc "NR>=60 && NR<=72"
                            ;;
                    esac
                    ;;
                -go|go)
                    if [ -z "$3" ]; then
                        read_doc $doc "NR>=74 && NR<=83"
                        return 1
                    fi

                    student_name="$3"
                    module_number="$4"

                    iods go "$student_name" "$module_number"
                    ;;
                -get)
                    if [ -z "$3" ]; then
                        read_doc $doc "NR=21"
                        return 1
                    fi

                    get_student "$3"
                    ;;
                -labs|labs|l)
                    if [ -z "$4" ]; then
                        read_doc $doc "NR>=22 && NR<=23"
                        return 1
                    fi

                    student_name="$3"
                    module_number="$4"
                    repo_url="$5"
                    shift 5

                    iods labs "$student_name" "$module_number" "$repo_url" "$@"
                    ;;
                *)
                    read_doc $doc "NR>=28 && NR<=47"
                    ;;
            esac
            ;;
        *)
            read_doc $doc "NR<=26"
            ;;
    esac
}