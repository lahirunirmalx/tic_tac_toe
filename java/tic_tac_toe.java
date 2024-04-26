import java.util.Scanner;

public class TicTacToe {
    private static final int BOARD_SIZE = 9;

    // Create a tic-tac-toe board
    private static void createBoard(char[] board, String template, StringBuilder output) {
        output.setLength(0); // Clear previous output
        output.append(template);
        for (int i = 0; i < BOARD_SIZE; i++) {
            String token = "{" + i + "}";
            int tokenIndex;
            while ((tokenIndex = output.indexOf(token)) != -1) {
                output.replace(tokenIndex, tokenIndex + 3, String.valueOf(board[i]) + "  ");
            }
        }
    }

    // Check for a win condition
    private static boolean checkWin(char player, char[] board) {
        int[][] winConditions = {
            {0, 1, 2}, {3, 4, 5}, {6, 7, 8},
            {0, 3, 6}, {1, 4, 7}, {2, 5, 8},
            {0, 4, 8}, {2, 4, 6}
        };

        for (int[] condition : winConditions) {
            if (board[condition[0]] == player &&
                board[condition[1]] == player &&
                board[condition[2]] == player) {
                return true;
            }
        }

        return false;
    }

    // Bot player to make a move
    private static int botPlayer(char[] board) {
        int[][] winConditions = {
            {0, 1, 2}, {3, 4, 5}, {6, 7, 8},
            {0, 3, 6}, {1, 4, 7}, {2, 5, 8},
            {0, 4, 8}, {2, 4, 6}
        };

        if (board[4] == ' ') {
            return 4; // Middle move
        }

        int[] blockableMoves = new int[8]; // To keep track of blockable moves
        int blockableIndex = 0;

        for (int[] condition : winConditions) {
            int xCount = 0;
            int emptyIndex = -1;
            for (int pos : condition) {
                if (board[pos] == 'X') {
                    xCount++;
                } else if (board[pos] == ' ') {
                    emptyIndex = pos;
                }
            }

            if (xCount == 2 && emptyIndex != -1) {
                return emptyIndex; // Block winning move
            }

            if (xCount == 1 && emptyIndex != -1) {
                blockableMoves[blockableIndex++] = emptyIndex; // Record potential move
            }
        }

        return blockableMoves[0]; // Return the first valid move
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        // Initial board setup
        String boardTemplate = 
            "       0     1     2\n"+
            "    +-----+-----+-----+\n"+
            "    | {0} | {1} | {2} |\n"+
            "    +-----+-----+-----+\n"+
            "  3 | {3} | {4} | {5} | 5\n"+
            "    +-----+-----+-----+\n"+
            "    | {6} | {7} | {8} |\n"+
            "    +-----+-----+-----+\n"+
            "       6     7     8\n";

        char[] squares = new char[BOARD_SIZE];
        for (int i = 0; i < BOARD_SIZE; i++) {
            squares[i] = ' ';
        }

        char[] players = {'X', 'O'};
        int currentPlayer = 0;
        StringBuilder formattedBoard = new StringBuilder(1024);

        while (true) {
            // Clear the console (ANSI escape sequence for clear screen)
            System.out.print("\033[H\033[2J");
            System.out.flush();

            createBoard(squares, boardTemplate, formattedBoard);
            System.out.println(formattedBoard.toString());

            if (checkWin(players[currentPlayer], squares)) {
                System.out.printf("Player %c is the winner!\n", players[currentPlayer]);
                break;
            }

            // Check for tie
            boolean hasEmptySpot = false;
            for (char square : squares) {
                if (square == ' ') {
                    hasEmptySpot = true;
                    break;
                }
            }

            if (!hasEmptySpot) {
                System.out.println("Cat's game!");
                break;
            }

            int move = -1;
            if (currentPlayer == 0) { // Player 1 input
                do {
                    System.out.printf("Player %c to move [0-8] > ", players[currentPlayer]);
                    if (!scanner.hasNextInt()) {
                        System.out.println("Invalid move!");
                        scanner.next(); // Clear invalid input
                        move = -1;
                    } else {
                        move = scanner.nextInt();
                        if (move < 0 || move > 8 || squares[move] != ' ') {
                            System.out.println("Invalid move!");
                            move = -1;
                        }
                    }
                } while (move == -1);
            } else { // Bot move
                move = botPlayer(squares);
            }

            squares[move] = players[currentPlayer];

            if (checkWin(players[currentPlayer], squares)) {
                System.out.printf("Player %c is the winner!\n", players[currentPlayer]);
                break;
            }

            // Switch player
            currentPlayer = (currentPlayer + 1) % 2;
        }

        scanner.close();
    }
}
