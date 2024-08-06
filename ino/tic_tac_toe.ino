#include <Adafruit_SSD1306.h>
#include <Wire.h>
#include <Keypad.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define BOARD_SIZE 9
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels
#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32


Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void createBoard(char board[], const char *template1, char *output1) ;
bool checkWin(char player, char board[]);
int botPlayer(char board[]);

const uint8_t ROWS = 4;
const uint8_t COLS = 4;
char keys[ROWS][COLS] = {
  { '1', '2', '3', 'A' },
  { '4', '5', '6', 'B' },
  { '7', '8', '9', 'C' },
  { '*', '0', '#', 'D' }
};

uint8_t colPins[COLS] = { 10, 1, 3, 2 }; // Pins connected to C1, C2, C3, C4
uint8_t rowPins[ROWS] = { 19, 18, 4, 5 }; // Pins connected to R1, R2, R3, R4

Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);
char boardTemplate[] = 
        "      0   1   2\n"
        "    +---+---+---+\n"
        "    |{0}|{1}|{2}|\n"
        "    +---+---+---+\n"
        "  3 |{3}|{4}|{5}| 5\n"
        "    +---+---+---+\n"
        "    |{6}|{7}|{8}|\n"
        "    +---+---+---+\n"
        "      6   7   8\n"; 
    char players[2] = {'X', 'O'};
    int currentPlayer = 0;
    char formattedBoard[1024];
    char squares[BOARD_SIZE];
void setup() {
  Serial.begin(115200);

  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;); // Don't proceed, loop forever
  }

  display.clearDisplay();
  display.setTextSize(1);           
  display.setTextColor(SSD1306_WHITE);      
  display.setCursor(0,0); 
  //display.println(F(boardTemplate));
  display.display();
    
    for (int i = 0; i < BOARD_SIZE; i++) {
        squares[i] = ' ';
    }

   
  delay(1000);
}

void loop() {
  display.clearDisplay();
  display.setTextSize(1);           
  display.setTextColor(SSD1306_WHITE);      
  display.setCursor(0,0); 
  createBoard(squares, boardTemplate, formattedBoard);
  display.println(F(formattedBoard));
  display.display();
        if (checkWin(players[currentPlayer], squares)) {
           display.clearDisplay();
  display.setTextSize(1);           
  display.setTextColor(SSD1306_WHITE);      
  display.setCursor(0,0); 
  char token[25] ;
  snprintf(token, sizeof(token), "Player %c is the winner!", players[currentPlayer]);
            display.println(F(token));
            display.display();
             for (;;);
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
            display.clearDisplay();
  display.setTextSize(1);           
  display.setTextColor(SSD1306_WHITE);      
  display.setCursor(0,0);
             display.print("Cat's game!\n");
             display.display();
             for (;;);
        }
        Serial.println("here"); 
        int move = -1;
        if (currentPlayer == 0) {
           move = keypad.getKey(); // Player 1 input
            do {  
             
              Serial.println(move);
                if (  move == NO_KEY || move < 0 || move > 8 || squares[move] != ' ') {
                    display.print("Invalid move!\n"); 
                    //move = NO_KEY;
                    move = keypad.getKey();
                }
            } while (move == NO_KEY);
        } else { // Bot move
            move = botPlayer(squares);
        }

        squares[move] = players[currentPlayer];

        if (checkWin(players[currentPlayer], squares)) {
          display.clearDisplay();
  display.setTextSize(1);           
  display.setTextColor(SSD1306_WHITE);      
  display.setCursor(0,0);
  char token[25] ;
  snprintf(token, sizeof(token), "Player %c is the winner!", players[currentPlayer]);
             display.println(F(token));
            for (;;);
        }

        // Switch player
        currentPlayer = (currentPlayer + 1) % 2;
         display.display();
}



// Create a tic-tac-toe board
void createBoard(char board[], const char *template1, char *output1) {
    strcpy(output1, template1);
    for (int i = 0; i < BOARD_SIZE; i++) {
        char token[4];
        snprintf(token, sizeof(token), "{%d}", i);
        for (int j = 0; j < strlen(output1); j++) {
            if (output1[j] == '{' && output1[j + 1] == (char) ('0' + i) && output1[j + 2] == '}') {
                output1[j] = board[i];
                output1[j + 1] = ' ';
                output1[j + 2] = ' ';
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

 
