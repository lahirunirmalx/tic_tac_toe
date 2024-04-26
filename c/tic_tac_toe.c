#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define BOARD_SIZE 9

// Create a tic-tac-toe board
void createBoard(char board[], const char *template, char *output) {
    strcpy(output, template);
    for (int i = 0; i < BOARD_SIZE; i++) {
        char token[4];
        snprintf(token, sizeof(token), "{%d}", i);
        for (int j = 0; j < strlen(output); j++) {
            if (output[j] == '{' && output[j + 1] == (char) ('0' + i) && output[j + 2] == '}') {
                output[j] = board[i];
                output[j + 1] = ' ';
                output[j + 2] = ' ';
            }
        }
    }
}

// Check for a win condition
bool checkWin(char player, char board[]) {
    int winConditions[8][3] = {
        {0, 1, 2}, {3, 4, 5}, {6, 7, 8},
        {0, 3, 6}, {1, 4, 7}, {2, 5, 8},
        {0, 4, 8}, {2, 4, 6}
    };

    for (int i = 0; i < 8; i++) {
        if (board[winConditions[i][0]] == player &&
            board[winConditions[i][1]] == player &&
            board[winConditions[i][2]] == player) {
            return true;
        }
    }

    return false;
}

// Bot player to make a move
int botPlayer(char board[]) {
    int winConditions[8][3] = {
        {0, 1, 2}, {3, 4, 5}, {6, 7, 8},
        {0, 3, 6}, {1, 4, 7}, {2, 5, 8},
        {0, 4, 8}, {2, 4, 6}
    };

    if (board[4] == ' ') {
        return 4; // Middle move
    }

    int blockableMoves[8] = {0}; // to keep track of blockable moves
    int blockableIndex = 0;

    for (int i = 0; i < 8; i++) {
        int xCount = 0, emptyIndex = -1;
        for (int j = 0; j < 3; j++) {
            if (board[winConditions[i][j]] == 'X') {
                xCount++;
            } else if (board[winConditions[i][j]] == ' ') {
                emptyIndex = winConditions[i][j];
            }
        }

        if (xCount == 2 && emptyIndex != -1) {
            return emptyIndex; // Block winning move
        }

        if (xCount == 1 && emptyIndex != -1) {
            blockableMoves[blockableIndex++] = emptyIndex; // Record potential move
        }
    }

    // Return the first valid move
    return blockableMoves[0];
}

// The main game loop
int main() {
    // Initial board setup
    char boardTemplate[] = 
        "       0     1     2\n"
        "    +-----+-----+-----+\n"
        "    | {0} | {1} | {2} |\n"
        "    +-----+-----+-----+\n"
        "  3 | {3} | {4} | {5} | 5\n"
        "    +-----+-----+-----+\n"
        "    | {6} | {7} | {8} |\n"
        "    +-----+-----+-----+\n"
        "       6     7     8\n";

    char squares[BOARD_SIZE];
    for (int i = 0; i < BOARD_SIZE; i++) {
        squares[i] = ' ';
    }

    char players[2] = {'X', 'O'};
    int currentPlayer = 0;
    char formattedBoard[1024];

    while (true) {
        printf("\033\143"); // Clear the console
        createBoard(squares, boardTemplate, formattedBoard);
        printf("%s\n", formattedBoard);

        if (checkWin(players[currentPlayer], squares)) {
            printf("Player %c is the winner!\n", players[currentPlayer]);
            break;
        }

        // Check for tie
        bool hasEmptySpot = false;
        for (int i = 0; i < BOARD_SIZE; i++) {
            if (squares[i] == ' ') {
                hasEmptySpot = true;
                break;
            }
        }

        if (!hasEmptySpot) {
            printf("Cat's game!\n");
            break;
        }

        int move = -1;
        if (currentPlayer == 0) { // Player 1 input
            do {
                printf("Player %c to move [0-8] > ", players[currentPlayer]);
                int read = scanf("%d", &move);
                if (read == 0 || move < 0 || move > 8 || squares[move] != ' ') {
                    printf("Invalid move!\n");
                    fflush(stdin); // Clear invalid input
                    move = -1;
                }
            } while (move == -1);
        } else { // Bot move
            move = botPlayer(squares);
        }

        squares[move] = players[currentPlayer];

        if (checkWin(players[currentPlayer], squares)) {
            printf("Player %c is the winner!\n", players[currentPlayer]);
            break;
        }

        // Switch player
        currentPlayer = (currentPlayer + 1) % 2;
    }

    return 0;
}
