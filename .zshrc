source /usr/local/opt/spaceship/spaceship.zsh
export PATH="/usr/local/opt/mongodb-community@5.0/bin:$PATH"
export JAVA_HOME="/usr/bin/java"

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '
alias bp='vim ~/.zshrc'
alias sa='source ~/.zshrc;echo "ZSH aliases sourced."'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

 source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# loading bar
# Usage: loading_bar <duration: 0.2> <color: YELLOW> <message: Searching:>
loading_bar() {
    local width=20
    local duration=${1:-0.2}
    local i

    color=${2:-"$YELLOW"}
    msg=${3:-Searching:}

    echo -n -e "$msg"

    while true; do
        sleep "$duration"
        echo -n -e "${color}█${RESET}"
        ((width--))

        if [ "$width" -eq 0 ]; then
            break
        fi
    done

    tput cuu1

    echo
    echo "Loading complete       "
}

# colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
DARKGRAY='\e[38;5;240m'
ORANGE='\e[38;5;208m'
RESET='\033[0m'
# bg colors
BLUEBG='\e[44;30m'
REDBG='\e[41m'
YELLOWBG='\e[43;30m'
MAGENTABG='\e[1;45m'
CYANBG='\e[46m'
ORANGEBG='\e[48;5;208;30m'
WHITEBG='\e[47m'
INVERTED='\e[7m'
BLUEWHITE="\e[47;34m"
# PS3 bg
PS3BLUEBG="%K{blue}"
PS3ORANGEBG="%K{orange}"
# PS3 fore
PS3ORANGE="%F{orange}"
PS3BLUE="%F{blue}"
PS3RESET="%f"

frmt() {
    settings_file="$HOME/Library/Application Support/Code/User/settings.json"

    if grep -q '"editor.formatOnSave": true' "$settings_file" || grep -q '"editor.formatOnPaste": true' "$settings_file"; then
        sed -i '' 's/"editor.formatOnSave": true/"editor.formatOnSave": false/' "$settings_file"
        sed -i '' 's/"editor.formatOnPaste": true/"editor.formatOnPaste": false/' "$settings_file"
        loading_bar 0.01 ${RED} DISABLING:
        tput cuu1
        echo -e "${RED}❌ Auto-formatting DISABLED in VS Code.${RESET}"
        echo -e "${DARKGRAY} ⎿ Auto-formatting on Save DISABLED.${RESET}"
        echo -e "${DARKGRAY} ⎿ Auto-formatting on Paste DISABLED.${RESET}"
    else
        sed -i '' 's/"editor.formatOnSave": false/"editor.formatOnSave": true/' "$settings_file"
        sed -i '' 's/"editor.formatOnPaste": false/"editor.formatOnPaste": true/' "$settings_file"
        loading_bar 0.01 ${GREEN} ENABLING:
        tput cuu1
        echo -e "${GREEN}✅ Auto-formatting ENABLED in VS Code.${RESET}"
        echo -e "${DARKGRAY} ⎿ Auto-formatting on Save ENABLED.${RESET}"
        echo -e "${DARKGRAY} ⎿ Auto-formatting on Paste ENABLED.${RESET}"
        echo -e "${BLUE} Start the server? (yes/no): ${RESET}"
    fi
}

function mkdir
{
  command mkdir $1 && cd $1
}
alias work="cd ~/workspace"
alias docs="cd ~/documents/Docs && open . && cd"
alias howick="cd ~/howick/hcs"

# personal workspace stuff

workspace() {
    case "$1" in
        open)
            if [ -z "$2" ]; then
                echo "Usage: workspace open [ -o | -u | -p <project_folder> ]"
                echo "workspace open -o                 Navigates to workspace and Open Finder"
                echo "workspace open -u                 Navigates to workspace/utils and Open VS Code"
                echo "workspace open -p <folder_name>   Navigates to specified project folder and Open VS Code"
                return 1
            fi

            folder_name=""
            open_utils_flag=""
            open_finder_flag=""
            open_project_flag=""
            open_zshrc_flag=""
            open_helper=""
            open_finder_helper=""
            open_project_helper=""
            open_zshrc_helper=""

            while [ "$#" -gt 0 ]; do
                case "$1" in
                    -o|--open-finder)
                        open_finder_flag=true
                        shift
                        open_finder_helper="open"
                        ;;
                    -u|--open-utils)
                        open_utils_flag=true
                        shift
                        open_helper="open"
                        ;;
                    -z|--open-zshrc)
                        open_zshrc_flag=true
                        shift
                        open_zshrc_helper="open"
                        ;;
                    -p|--open-project)
                        if [ -z "$2" ]; then
                            echo -e "${GREEN}Please provide a project folder with -p option${RESET}"
                            return 1
                        fi

                        open_project_flag=true
                        work
                        folder_name="$2"

                        if [ ! -d "$folder_name" ]; then
                            echo -e "${RED}${folder_name} folder doesn't exist${RESET}"
                            return 1
                        fi

                        shift 2
                        open_project_helper="open"
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            folder_path="~/workspace/$folder_name"

            if [ -n "$open_finder_helper" ]; then
                echo -e "${BLUE} Opening finder... ${RESET}"
                work && open .
            fi

            if [ -n "$open_zshrc_helper" ]; then
                echo -e "${MAGENTABG} Opening .zshrc... ${RESET}"
                (cd ~/workspace/mac-zshrc && code .)
            fi

            if [ -n "$open_helper" ]; then
                echo -e "${BLUE} Opening Utils Folder... ${RESET}"
                (cd ~/workspace/utils && code .)
            fi

            if [ -n "$open_project_helper" ]; then
                if [ ! -d "$folder_name" ]; then
                    echo -e "${RED} ${folder_name} folder doesn't exist${RESET}"
                    return 1
                fi

                echo -e "${BLUE} Opening ${folder_name}... ${RESET}"
                (cd "$folder_name" && code .)
            fi
            ;;

        create)
            if [ -z "$2" ]; then
                echo "Usage: workspace create folder_name"
                return 1
            fi

            workspace_path=~/workspace
            new_folder_path="$workspace_path/$2"
            open_vscode_flag=""
            open_helper=""

            if [ -d "$new_folder_path" ]; then
                echo "Error: Folder '$2' already exists in the workspace."
                return 1
            fi

            mkdir "$new_folder_path"

            while [ "$#" -gt 0 ]; do
                case "$1" in
                    -o|--open-vscode)
                        open_vscode_flag=true
                        shift
                        open_helper="open"
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            if [ -n "$open_helper" ]; then
                code .
            fi
            ;;

        git)
            case "$2" in
                -c)
                    if [ -z "$3" ]; then
                        echo "Usage: workspace git -c <repo_url>"
                        return 1
                    fi

                    git_repo_url="$3"
                    clones_folder=~/workspace/clones
                    new_folder_path="$clones_folder/$(basename $git_repo_url .git)"

                    if [ -d "$new_folder_path" ]; then
                        echo "Error: Repository '$git_repo_url' already cloned in the 'clones' folder."
                        return 1
                    fi

                    mkdir "$new_folder_path"
                    git clone "$git_repo_url"
                    ;;

                *)
                    if [ -z "$2" ] || [ -z "$3" ]; then
                        echo "Usage: workspace git <repo_url> <folder_name>"
                        return 1
                    fi

                    git_repo_url="$2"
                    folder_name="$3"
                    workspace_path=~/workspace
                    new_folder_path="$workspace_path/$folder_name"

                    if [ -d "$new_folder_path" ]; then
                        echo "Error: Folder '$folder_name' already exists in the workspace."
                        return 1
                    fi

                    mkdir "$new_folder_path"
                    git clone "$git_repo_url" .
                    ;;
            esac
            ;;

        invoice)
            if [ -z "$1" ]; then
                echo "Usage: workspace invoice"
                echo -e "${DARKGRAY}workspace${RESET} invoice           Navigates to workspace/IOD_personal and Open IOD Invoice document"
                return 1
            fi

            cd "$HOME/workspace/IOD personal/2023-10-10-se-pt-nz-rem"
            loading_bar 0.01 ${BLUE} Navigating
            tput cuu1
            echo -e "${BLUE} Opening IOD Invoice ${RESET}"
            tput cuu1
            echo
            tput cuu1
            echo -e "❖ ${BLUEBG} Completed ${RESET} 〉${DARKGRAY} template-iod-invoice.pages ${RESET}"
            echo
            open template-iod-invoice.pages
            ;;
        *)
            echo "Usage: workspace [open [ -o | -u ] | create <folder_name> | git [ -c <repo_url> | <repo_url> <folder_name>]]"
            echo
            echo "workspace open -o                         Navigates to workspace and Open Finder"
            echo "workspace open -u                         Navigates to workspace/utils and Open VS Code"
            echo "workspace open -p <project_folder>        Navigates to workspace, Open a specific project and Open VS Code"
            echo "workspace create <folder>                 Creates a folder in the workspace folder"
            echo "workspace git -c <repo_url>               Navigates to workspace/clones folder and clones a repo from git"
            echo "workspace git <repo_url> <folder_name>    Creates a folder in workspace folder and clones a repo"
            echo "workspace invoice                         Navigates to workspace/IOD_personal and Open IOD Invoice document"
            ;;
    esac
}



iods() {
    case "$1" in
        go)
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo "Usage: iods go <student_name> <module_number>"
                echo
                echo "iods go <student_name> <module#>      Navigate to students specific lab module & Open VS Code"
                echo "iods go <student_name> -c             Navigate to students capstone folder & Open VS Code"
                return 1
            fi

            student_name="$2"
            module_number="$3"
            lab_folder="$HOME/iod/students/$student_name/Laboratory Exercises/Module $module_number"

            if [ "$module_number" = "-c" ]; then
                loading_bar 0.02
                echo -e "${YELLOWBG} Heading to the Capstone folder ${RESET}"

                capstone_folder="$HOME/iod/students/$student_name/Capstone"
                if [ ! -d "$HOME/iod/students/$student_name/Capstone" ]; then
                    echo "Capstone folder not found"
                    cd "$HOME/iod/students/$student_name"

                    echo "Creating Capstone folder"
                    loading_bar 0.04
                    mkdir Capstone
                    tput cuu1
                    echo -e "${BLUE} Capstone folder Created ${RESET}"
                    echo -e "${BLUE} Launching VS Code ${RESET}"
                    loading_bar 0.01 ${BLUE} Launching
                    tput cuu1
                    echo -e "❖ ${ORANGEBG} IOD main ${RESET}  〉 ${DARKGRAY} ${student_name} Capstone ${RESET}"
                    code .
                    return 0
                else
                    cd "$capstone_folder"
                    code .
                    return 0
                fi
            fi


            attempts_module=0
            while [ "$attempts_module" -lt 3 ]; do
                    if [ -d "$lab_folder" ]; then
                        loading_bar 0.03
                        tput cuu1
                        echo -e "${GREEN} MODULE FOUND. loading options ${RESET} "
                        cd "$lab_folder" || { echo -e "${RED}Failed to cd to $lab_folder${RESET}"; return 1; }

                        echo -e "${BLUEBG} Contents of the module folder: ${RESET}"
                        PS3="▶︎ ${PS3BLUE}Select a subfolder (or press Enter to continue):${PS3RESET}"

                        subfolders=($(find . -maxdepth 1 -type d -exec basename {} \;))
                        num_subfolders=${#subfolders[@]}

                        select subfolder_input in "${subfolders[@]}"; do
                            if [ -z "$subfolder_input" ]; then
                                break
                            fi

                            selected_subfolder="./$subfolder_input"

                            if [ -d "$selected_subfolder" ]; then
                                cd "$selected_subfolder" || { echo -e "${RED}Failed to cd to $selected_subfolder${RESET}"; return 1; }
                                echo -e "${BLUE} Launching VS Code ${RESET}"
                                loading_bar 0.01 ${BLUE} Launching
                                tput cuu1
                                echo -e "❖ ${ORANGEBG} IOD main ${RESET}  〉 ${DARKGRAY} ${student_name} ${selected_subfolder} ${RESET}"
                                code .
                                return 0
                            else
                                echo -e "${RED}Invalid selection. Please try again.${RESET}"
                            fi
                        done

                        echo -e "${YELLOWBG} No subfolder specified. Opening VS Code in the current folder ${RESET}"
                        echo -e "${BLUE} Launching VS Code ${RESET}"
                        loading_bar 0.01 ${BLUE} Launching
                        tput cuu1
                        echo -e "❖ ${ORANGEBG} IOD main ${RESET}  〉 ${DARKGRAY} ${student_name} ${selected_subfolder} ${RESET}"
                        code .
                        return 0
                    else
                        echo -e "${RED} lab folder not found for student: $student_name, module: $module_number ${RESET}"
                        if [ "$attempts_module" -eq 2 ]; then
                            echo -e "${RED} ⚠️ Too many invalid attempts. Performing ls instead. ${RESET}"
                            ls "$HOME/iod/students/$student_name/Laboratory Exercises/"
                            return 1
                        else
                            echo -n -e "  ▶︎ ${BLUEBG} Enter the correct module number: ${RESET}"
                            read module_number
                            lab_folder="$HOME/iod/students/$student_name/Laboratory Exercises/Module $module_number"
                            ((attempts_module++))
                        fi
                    fi
            done
            echo -e "${RED} ⚠️ Too many invalid attempts for student name. Returning to home directory. ${RESET}"
            cd ~
            return 1
            ;;
        labs)
            if [ -z "$2" ];  then
                echo "Usage: iods labs <student_name> <module#> <repo_url> <folder_name>"
                echo "Options:"
                echo "  -f, --folder <folder_name>    Specify folder name (optional)"
                return 1
            fi

            student_name="$2"
            module_number="$3"
            student_repo="$4"
            lab_folder="$HOME/iod/students/$student_name/Laboratory Exercises/Module $module_number"
            repo_folder="$lab_folder/$(basename $student_repo .git)"

            cd "$lab_folder" || { echo -e "${RED}Failed to cd to $lab_folder${RESET}"; return 1; }

            folder_flag=""
            folder_name=""
            open_vscode_flag=""
            open_helper=""

            while [ "$#" -gt 0 ]; do
                case "$1" in
                    -f|--folder)
                        folder_flag=true
                        shift
                        folder_name="$1"
                        ;;
                    -o|--open-vscode)
                        open_vscode_flag=true
                        shift
                        open_helper="open"
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            if [ -n "$folder_name" ]; then
                mkdir "$folder_name"
                repo_folder="$folder_name"
            fi

            git clone "$student_repo" || { echo -e "${RED}Failed to clone repository${RESET}"; return 1 ; }
            # cd "$repo_folder"
            # code .

            if [ ! -d "$repo_folder" ]; then
                echo -e "${RED} repo_folder doesn't exist ${RESET}"
                return 1
            fi

            if [ -n "$open_helper" ]; then
                code "$repo_folder"
            fi
            ;;
        *)
            echo "Usage: iods labs <student_name> <module#> <repo_url> [options]"
            echo "Options:"
            echo " -f, --folder <folder_name>   Specify folder name (optional)"
            echo " -o, --open-cloned            Navigate to cloned repository and Open VS Code (optional)"
            return 1
            ;;
    esac
}

# iod matters

students=("dale" "sarah" "nikki" "abby" "colin" "derek" "kevin" "tricia" "jackie" "ryan" "jack" "mat" "roda" "gia" "georgia" "ethan" "hashley" "tanmay")
students_lastname=("dale lambert" "sarah mcgregor" "nikki botha" "abby malbon" "colin campbell" "derek pham" "kevin wei dong" "tricia san juan" "jackie fang" "ryan cameron" "jack dodd" "mat dalghiranis" "roda samortin" "ngoc gia han" "georgia ridge" "ethan hyndman" "hashley beedah" "tanmay patel")
students_email=("ddlambert1@hotmail.com" "sarahmcgregor24@gmail.com" "botha.nieks@gmail.com" "abbymalbon10@gmail.com"  "colinjcampbell73@gmail.com" "derekpham3@gmail.com" "kevin.dongwei@hotmail.com" "sanjuantricia@ymail.com" "jackiefang98@hotmail.com" "ryancameron555@gmail.com"  "jackdoddpost@gmail.com" "mdalghiranis@gmail.com" "rodaasamortin@gmail.com" "hanpg99@gmail.com" "georgiamayridge97@gmail.com" "ethanm369@gmail.com"  "hashleyb@outlook.com" "patel.tanmayr@gmail.com")
students_usernames=("@Insaneowl1993" "@SimianPrimus" "@NiKi0706" "@a10mal" "@siege2000" "@derek-pham" "@kevinwdong" "@sunflowerbyte" "@TunaPigeon" "@Ryancameron555" "@Daelop" "@afloormat" "@rodasamortin" "@giahp" "@gmridge" "@HyndmanEthan" "@HashleyB" "@TanmayEke")

add_student() {
    student="$1"
    lastname="$2"
    email="$3"
    username="$4"

    students+=("$student")
    students_lastname+=("$lastname")
    students_email+=("$email")
    students_usernames+=("$username")
}

get_student() {
    student_name="$1"

    if [ -z "$1" ]; then
        echo "Usage: get_student <student_name>"
        return 1
    fi

    for ((i = 0; i < ${#students[@]}; i++)); do
        if [[ "${students[$i]}" == "$student_name" ]]; then
            echo -e "${INVERTED}Student:${RESET} ${students_lastname[$i]} | ${INVERTED}Email:${RESET} ${students_email[$i]} | ${INVERTED}Username:${RESET} ${students_usernames[$i]}"
            return
        fi
    done

    echo "Student not found: $student_name"
}

check() {
    attempts=0
    while [ "$attempts" -lt 3 ]; do
        echo -n -e "${BLUEBG}Enter the correct module number: ${RESET}"
        read module_number
        if [[ "$module_number" =~ ^[0-9]+$ ]]; then
             ((attempts++))
            echo "$attempts attempts"
            break
        else
            echo -e "${REDBG}Invalid input. Please enter a valid module number.${RESET}"
            ((attempts++))
            echo "$attempts attempts"
        fi
    done

    if [ "$attempts" -eq 3 ]; then
        echo "Too many invalid attempts. Returning to home directory."
        cd
        return
    fi
}
# main iod function
iod() {
    case "$1" in
        show)
            cd ~/iod
            loading_bar 0.01 ${BLUE} Navigating
            tput cuu1
            echo -e "${BLUE} Opening IOD main in VS Code ${RESET}"
            tput cuu1
            echo
            tput cuu1
            echo -e "❖ ${BLUEBG} Completed ${RESET} 〉${DARKGRAY} IOD ${RESET}"
            echo
            code .
            ;;
        go)
            if [ -z "$2" ]; then
                echo "Usage: iod go <module_number>"
                echo
                echo "iod go <module_number>        Navigate to labs folder with specific module and Open VS Code"
                echo "iod go -c                     Navigate to labs folder, specifically to Capstone"
                return
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
                                echo "$clone_folder"
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

        module)
            if [ -z "$2" ]; then
                echo "Usage: iod module <module_number> [ c ]"
                echo
                echo "iod module <module_number>    Navigate to modules folder, to specific module number and Open VS Code"
                echo "iod module -c                 Navigate to modules folder, to Capstone and Open VS Code"
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
                code .
                echo -e "${BLUEBG} Opening VS Code ${RESET}"
                return 0
            fi

            attempts_module=0
            while [ "$attempts_module" -lt 3 ]; do
                    if [ -d "$lab_folder" ]; then
                        loading_bar 0.03
                        tput cuu1
                        echo -e "${GREEN} MODULE Material. loading options ${RESET} "
                        cd "$module_folder" || { echo -e "${RED}Failed to cd to $lab_folder${RESET}"; return 1; }

                        echo -e "${BLUEBG} Contents of the module folder: ${RESET}"
                        PS3="Select a subfolder (or press Enter to continue):"

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
                                        pdf_to_open="${pdfs[0]}"
                                        echo -e "${GREEN}Opening PDF: $pdf_to_open${RESET}"

                                        if command -v open &> /dev/null; then
                                            open "$pdf_to_open"
                                        else
                                            echo -e "${RED}Command 'open' not found. Please manually open the file: $pdf_to_open${RESET}"
                                        fi
                                        return 0
                                    else
                                        echo -e "${BLUEBG}Choose a PDF to open: ${RESET}"

                                        # FIXME: the list doesn't match what is selected, index is not showing up
                                        counter=1
                                        for pdf in "${pdfs[@]}"; do
                                            echo " $counter. $pdf"
                                            ((counter++))
                                        done

                                        echo -n -e " Enter the PDF number (or 0 to cancel): "
                                        read -r pdf_option

                                        if [[ "$pdf_option" =~ ^[0-9]+$ ]] && [ "$pdf_option" -gt 0 ] && [ "$pdf_option" -le "$num_pdfs" ]; then
                                            selected_index=$((pdf_option - 1))
                                            pdf_to_open="${pdfs[selected_index]}"
                                            echo -e "${GREEN}Opening PDF: $pdf_to_open${RESET}"

                                            if command -v open &> /dev/null; then
                                                open "$pdf_to_open"
                                            else
                                                echo -e "${RED}Command 'open' not found. Please manually open the file: $pdf_to_open${RESET}"
                                            fi
                                            return 0

                                        elif [ "$pdf_option" -eq 20 ]; then
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
        students)
            case "$2" in
                -list)
                    case "$3" in
                        .)
                            printf "%s\n" "${students[@]}"
                            ;;
                        -l)
                            printf "%s\n" "${students_lastname[@]}"
                            ;;
                        -e)
                            printf "%s\n" "${students_email[@]}"
                            ;;
                        -u)
                            printf "%s\n" "${students_usernames[@]}"
                            ;;
                        -all)
                            echo -e "${YELLOW}Name\tLast Name\t\tEmail\t\t\tUsername${RESET}"
                            # echo -e "----\t---------\t\t-----\t\t\t--------"

                            echo -e "${YELLOWBG}                                                                                     ${RESET}"
                            for ((i = 0; i < ${#students[@]}; i++)); do
                                echo "${students[$i]}\t${students_lastname[$i]}\t${students_email[$i]}\t\t${students_usernames[$i]}"
                            done
                             echo -e "${YELLOWBG}                                                                                     ${RESET}"
                            ;;
                        *)
                            echo "Usage: iod students -list [ . | -l  | -e  | -u | -all ]"
                            echo "iod students -list .              Shows the list of students"
                            echo "iod students -list -l             Shows the list of students with lastname"
                            echo "iod students -list -e             Shows the list of students email"
                            echo "iod students -list -u             Shows the list of students Github username"
                            echo "iod students -list -all           Shows the list of students with all details"
                            ;;
                    esac
                    ;;
                -go)
                    if [ -z "$3" ]; then
                        echo "Usage: iod students -go <students_name> <module_number>"
                        echo
                        echo "iod students -go <student_name> <module_number>   Navigate to students specific lab folder and Open VS Code"
                        echo "iod students -go <student_name> -c                Navigate to students capstone folder and Open VS Code"

                        return
                    fi

                    student_name="$3"
                    module_number="$4"

                    iods go "$student_name" "$module_number"
                    ;;
                -get)
                    if [ -z "$3" ]; then
                        echo "Usage: iod students -get <student_name>"
                        return 1
                    fi

                    get_student "$3"
                    ;;
                -labs)
                    if [ -z "$4" ]; then
                        echo "Usage: iod students -labs <student_name> <module#> <repo_url> [options]"
                        return 1
                    fi

                    student_name="$3"
                    module_number="$4"
                    repo_url="$5"
                    shift 5

                    iods labs "$student_name" "$module_number" "$repo_url" "$@"
                    ;;
                *)
                    echo "Usage: iod students [ -list | -get | -labs ]"
                    echo
                    echo "iod students -list .                              Shows the list of students"
                    echo "iod students -list -l                             Shows the list of students with lastname"
                    echo "iod students -list -e                             Shows the list of students email"
                    echo "iod students -list -u                             Shows the list of students Github username"
                    echo "iod students -list -all                           Shows the list of students with all details"
                    echo "iod students -go <student_name> <module_number>   Navigate to students specific lab folder and Open VS Code"
                    echo "iod students -go <student_name> -c                Navigate to students capstone folder and Open VS Code"
                    echo "iod students -get <student_name>                  Shows the student details (full name, email and git username)"
                    echo
                    echo "iod students -labs <student_name> <module#> <repo_url> [options]..."
                    echo "                                                  ..Clone a repository to students laboratory exercises"
                    echo "Options:"
                    echo " -f --folder <folder_name>                        Specify the folder name (optional)"
                    ;;
            esac
            ;;
        *)
            echo "Usage: iod [ go | module | show | students [ -list [ . | -l | -e | -u ] | -labs ] ]"
            echo
            echo "iod show                                          Navigates to iod folder and open VS Code"
            echo "iod go -c                                         Navigates to labs capstone folder in iod and open VS Code"
            echo "iod go <module_number>                            Navigates to specific labs module folder in iod and open VS Code"
            echo "iod module <module_number>                        Navigate to modules folder, to specific module number and Open VS Code"
            echo "iod module -c                                     Navigate to modules folder, to Capstone and Open VS Code"
            echo "iod students -list .                              Shows the list of students"
            echo "iod students -list -l                             Shows the list of students with lastname"
            echo "iod students -list -e                             Shows the list of students email"
            echo "iod students -list -u                             Shows the list of students Github username"
            echo "iod students -go <student_name> <module_number>   Navigate to students specific lab folder and Open VS Code"
            echo "iod students -go <student_name> -c                Navigate to students capstone folder and Open VS Code"
	        echo "iod students -get <student_name>                  Shows the student details (full name, email and git username)"
            echo
            echo "iod students -labs <student_name> <module#> <repo_url> [options]..."
            echo "                                                  ..Clone a repository to students laboratory exercises"
            echo "Options:"
            echo " -f --folder <folder_name>                        Specify the folder name (optional)"
            ;;
    esac
}

# work stuff

hltd() {
    case "$1" in
	    this)
	    howick && cd ~/howick/hcs/hp_dev-new
	    ;;
        client)
            loading_bar 0.01 ${BLUE} NAVIGATING:
            tput cuu1
            echo -e "${BLUE} Opening Client in VS Code ${RESET}"
            howick && cd ~/howick/hcs/hp_dev-new   && code .
            tput cuu1
            echo -e "${BLUE} Launching Howick Portal ${RESET}"
            tput cuu1
            echo -e "❖ ${BLUEBG} Welcome to Howick Portal ${RESET} 〉 ${DARKGRAY} CLIENT ${RESET}"
            echo
            git log --oneline --abbrev-commit --all --graph --decorate --color -n 5
            echo
            echo -n -e "${BLUE} Start the Client? (yes/no):${RESET}\c"
            read start_client
            if [ "$start_client" = "yes" ]; then
                echo -e "${BLUE} Starting the client...${RESET}"
                npm start
            else
                echo -e "${YELLOWBG} Client not started.${RESET}"
            fi
            ;;
        server)
            loading_bar 0.01 ${ORANGE} NAVIGATING:y
            tput cuu1
            echo -e "${ORANGE} Opening Server in VS Code ${RESET}"
            howick && cd ~/howick/hcs/hp_server  && code .
            tput cuu1
            echo -e "${ORANGE} Launching Howick Portal ${RESET}"
            tput cuu1
            echo -e "❖ ${ORANGEBG} Welcome to Howick Portal ${RESET}  〉 ${DARKGRAY} SERVER ${RESET}"
            echo
            git log --oneline --abbrev-commit --all --graph --decorate --color -n 5
            echo
            echo -n -e"${ORANGE} Start the Server? (yes/no):${RESET}\c"
            read start_server
            if [ "$start_server" = "yes" ]; then
                echo -e "${ORANGE} Starting the server...${RESET}"
                npm start
            else
                echo -e "${YELLOWBG} Server not started.${RESET}"
            fi
            ;;
        *)
        echo "Usage: hltd [ this | client | server ]"
	    echo
	    echo "${DARKGRAY}hltd${RESET} this     Navigate to the howick portal UI local"
	    echo "${DARKGRAY}hltd${RESET} client   Navigate to the howick portal UI local and open VS Code (optional: start client)"
	    echo "${DARKGRAY}hltd${RESET} server   Navigate to the howick portal SERVER local and open VS Code (optional: start server)"
        ;;
    esac
}


