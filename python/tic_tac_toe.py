from typing import List

winConditions = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
]


def main():
    currentPlayer: bool = True
    boardTemplate: str = (
        "       0     1     2\n"
        "    +-----+-----+-----+\n"
        "    | {0} | {1} | {2} |\n"
        "    +-----+-----+-----+\n"
        "  3 | {3} | {4} | {5} | 5\n"
        "    +-----+-----+-----+\n"
        "    | {6} | {7} | {8} |\n"
        "    +-----+-----+-----+\n"
        "       6     7     8\n"
    )
    squares: List[str] = ["   " for i in range(9)]

    while True:
        print("\033[H\033[2J")
        print(createBoard(squares, boardTemplate))

        move: int = -1
        if currentPlayer:
            while move == -1:
                try:
                    move = int(
                        input(f"Player {'X' if currentPlayer else 'O'} to move [0-8] >")
                    )
                except ValueError:
                    print("Invalid input. Please enter a number between 0 and 8")
                    move = -1
                    continue
                if move < 0 or move > 8 or squares[move] != "   ":
                    print("Invalid input. Please enter a number between 0 and 8")
                    move = -1
                    continue
        else:
            move = botPlayer(squares)

        squares[move] = " X " if currentPlayer else " O "

        if checkWin(currentPlayer, squares):
            print(createBoard(squares, boardTemplate))
            print(f"Player {'X' if currentPlayer else 'O'} wins!")
            return
        emptySpot: bool = False
        for spot in squares:
            if spot == "   ":
                emptySpot = True
                break
        if not emptySpot:
            print("Cat's game!")
            return

        currentPlayer = not currentPlayer


def createBoard(squares: List[str], boardTemplate: str):
    formattedBoard: str = str()
    formattedBoard = boardTemplate.format(*squares)
    return formattedBoard


def botPlayer(squares: List[str]) -> int:
    print("Bot's turn")
    if squares[4] == "   ":
        return 4
    blockableMoves: List[int] = []

    for condition in winConditions:
        for vacantPosition in range(3):
            if (
                squares[condition[vacantPosition]] == "   "
                and squares[condition[(vacantPosition + 1) % 3]] == " X "
                and squares[condition[(vacantPosition + 2) % 3]] == " X "
            ):
                blockableMoves.append(condition[vacantPosition])
    if not blockableMoves:
        for square in squares:
            if square == "   ":
                return squares.index(square)
    return blockableMoves[0]


def checkWin(currentPlayer: bool, squares: List[int]):
    playerMark: str = " X " if currentPlayer else " O "
    for condition in winConditions:
        if (
            squares[condition[0]] == playerMark
            and squares[condition[1]] == playerMark
            and squares[condition[2]] == playerMark
        ):
            return True
    return False


if __name__ == "__main__":
    main()
