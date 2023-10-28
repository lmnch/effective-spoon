#!/bin/bash

DATA_FILE=$1
LAST_OUTPUT_LINE=50

LAST_OUTPUT_LINE=$((LAST_OUTPUT_LINE - 1))

read_file() {
    INPUT_KEY=$1

    while IFS= read -r line; 
    do 
        # Get key
        key=$(echo "$line" | sed -e 's/\=.*//')
        # Value
        value=$(echo "$line" | sed -e 's/.*\=//')

        if [ "$key" = "$INPUT_KEY" ]; then
            echo $value
        fi
    done < $DATA_FILE
}

# Returns history text box content in the format:
# History
#
# alacritty
# echo 
# ...
#
# Therefore it uses the value of the HISTORY variable
get_history() {
    printf "History\n"
    counter=2
    while IFS=';' read -ra ADDR; do
        for i in "${ADDR[@]}"; do
            printf "$i\n"
        done
    done <<< "$HISTORY"

}

get_matching_commands(){
    INPUT_KEY=$1

    echo "Matching commands:"
    while IFS= read -r line; 
    do 
        # Get key
        key=$(echo "$line" | sed -e 's/\=.*//')
        # Value
        value=$(echo "$line" | sed -e 's/.*\=//')

        if [[ "${key}" == "${INPUT_KEY}"* ]]; then
            echo "$key=$value"
        fi
    done < $DATA_FILE
}

get_command_output() {
    printf "$COMMAND_OUTPUT"
}


p() {
    left=$1
    center=$2
    right=$3

    columns="$(tput cols)"

    padding=0
    printf "%*s" $padding "$left"  
    padding=$(((columns - ${#center} ) / 2 - ${#left}))
    printf "%*s" $padding "$center"
    padding=$(( columns - (padding + ${#center} + ${#left}) ))
    printf "%*s\n" $padding "$right"
}


# Initializes the Screen variable
init_screen() {
    declare -A Screen
    for i in $(seq 0 $LAST_OUTPUT_LINE); do 
        Screen[$i,0]=""
        Screen[$i,1]=""
        Screen[$i,2]=""
    done
}

# Writes sth in the format:
# *y*
# *x*
# History
#
# alacritty
# echo 
# ...
# to the Screen variable
print_box() {
    box="$@"
    # first y cordinate
    starty=$(printf "$box" 2>&1 | head -n 1)
    # x position
    x=$(printf "$box" 2>&1 | head -n 2 | tail -n 1)
    line_count=$(printf "$box" | wc -l)
    for index in $(seq 3 $((line_count+1))); do
        y=$((starty + index - 1))
        cell_content=$(sed -n ${index}p <<<"$box")
        Screen[$y,$x]=$cell_content
    done
}


# Print Screen
render_screen() {
     for i in $(seq 0 $LAST_OUTPUT_LINE); do 
         p "${Screen[$i,0]}" "${Screen[$i,1]}" "${Screen[$i,2]}"
     done
}


while : 
do
    clear

    echo ""
    figlet -w $(tput cols) "\$   $shortcut"

    init_screen

    print_box "$(echo -e "1\n2\n$(get_history)\n")"
    print_box "$(echo -e "1\n0\n$(get_matching_commands $shortcut)\n")"
    print_box "$(echo -e "1\n1\n$(get_command_output)\n")"

    render_screen

    # Read users input 
    read -n1 shortcut_input
    if [[ $shortcut_input = "#" ]]; then
        # Clear current input
        shortcut="" 
    else
        shortcut="$shortcut$shortcut_input"

        cmd=$(read_file $shortcut)
        if [ -n "$cmd" ]; then
            COMMAND_OUTPUT=$($cmd)
            if [ -z $HISTORY ]; then
                HISTORY=$cmd
            else
                HISTORY="$HISTORY;$cmd"
            fi
            shortcut=""
        fi
    fi
done
