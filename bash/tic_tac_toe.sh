#!/bin/bash

# Tic-tac-toe script in Bash

BOARD_SIZE=9
TEMPLATE=(
    "       0     1     2"
    "    +-----+-----+-----+"
    "    | {0} | {1} | {2} |"
    "    +-----+-----+-----+"
    "  3 | {3} | {4} | {5} | 5"
    "    +-----+-----+-----+"
    "    | {6} | {7} | {8} |"
    "    +-----+-----+-----+"
    "       6     7     8"
)

# Create a tic-tac-toe board
createBoard() {
    local -n board=$1
    local -n output=$2
    local i j token

    output=("${TEMPLATE[@]}")
    for ((i = 0; i < BOARD_SIZE; i++)); do
        token="{${i}}"
        for ((j = 0; j < ${#output[@]}; j++)); do
            output[j]=$(echo "${output[j]}" | sed "s/${token}/${board[$i]}  /g")
        done
    done
}

# Check for a win condition
checkWin() {
    local player=$1
    local -n board=$2
    local winConditions=(
        "0 1 2" "3 4 5" "6 7 8"
        "0 3 6" "1 4 7" "2 5 8"
        "0 4 8" "2 4 6"
    )

    for cond in "${winConditions[@]}"; do
        read -a indices <<< "$cond"
        if [[ "${board[indices[0]]}" == "$player" &&
              "${board[indices[1]]}" == "$player" &&
              "${board[indices[2]]}" == "$player" ]]; then
            return 0
        fi
    done
    return 1
}

# Bot player to make a move
botPlayer() {
    local -n board=$1
    local winConditions=(
        "0 1 2" "3 4 5" "6 7 8"
        "0 3 6" "1 4 7" "2 5 8"
        "0 4 8" "2 4 6"
    )

    if [[ "${board[4]}" == " " ]]; then
        echo 4
        return
    fi

    local blockableMoves=()
    for cond in "${winConditions[@]}"; do
        read -a indices <<< "$cond"
        xCount=0
        emptyIndex=-1
        for i in "${indices[@]}"; do
            if [[ "${board[i]}" == "X" ]]; then
                ((xCount++))
            elif [[ "${board[i]}" == " " ]]; then
                emptyIndex="$i"
            fi
        done
        if ((xCount == 2 && emptyIndex != -1)); then
            echo "$emptyIndex"
            return
        fi
        if ((xCount == 1 && emptyIndex != -1)); then
            blockableMoves+=("$emptyIndex")
        fi
    done

    echo "${blockableMoves[0]}"
}

# Main game loop
main() {
    squares=()
    for ((i = 0; i < BOARD_SIZE; i++)); do
        squares+=(" ")
    done

    players=("X" "O")
    currentPlayer=0
    formattedBoard=()

    while true; do
        clear
        createBoard squares formattedBoard
        for line in "${formattedBoard[@]}"; do
            echo "$line"
        done

        if checkWin "${players[currentPlayer]}" squares; then
            echo "Player ${players[currentPlayer]} is the winner!"
            break
        fi

        hasEmptySpot=false
        for square in "${squares[@]}"; do
            if [[ "$square" == " " ]]; then
                hasEmptySpot=true
                break
            fi
        done

        if ! $hasEmptySpot; then
            echo "Cat's game!"
            break
        fi

        move=-1
        if ((currentPlayer == 0)); then
            while [[ $move -lt 0 || $move -gt 8 || "${squares[move]}" != " " ]]; do
                echo -n "Player ${players[currentPlayer]} to move [0-8] > "
                read move
                if [[ $move -lt 0 || $move -gt 8 || "${squares[move]}" != " " ]]; then
                    echo "Invalid move!"
                    move=-1
                fi
            done
        else
            move=$(botPlayer squares)
        fi

        squares[move]=${players[currentPlayer]}
        currentPlayer=$(((currentPlayer + 1) % 2))
    done
}

main
