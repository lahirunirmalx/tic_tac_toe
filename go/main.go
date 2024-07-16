package main

import (
	"fmt"
	"strings"
)

var winConditions = [8][3]uint8{
	{0, 1, 2},
	{3, 4, 5},
	{6, 7, 8},
	{0, 3, 6},
	{1, 4, 7},
	{2, 5, 8},
	{0, 4, 8},
	{2, 4, 6},
}

var boardTemplate = string(
	"       0     1     2\n" +
		"    +-----+-----+-----+\n" +
		"    | {0} | {1} | {2} |\n" +
		"    +-----+-----+-----+\n" +
		"  3 | {3} | {4} | {5} | 5\n" +
		"    +-----+-----+-----+\n" +
		"    | {6} | {7} | {8} |\n" +
		"    +-----+-----+-----+\n" +
		"       6     7     8\n",
)

func createBoard(squares *[9]string, boardTemplate string) string {
	for i := 0; i < 9; i++ {
		boardTemplate = strings.Replace(boardTemplate, fmt.Sprintf("{%d}", i), strings.Join([]string{" ", (*squares)[i], " "}, ""), -1)
	}
	return boardTemplate
}

func botPlayer(squares *[9]string) uint8 {
	fmt.Println("Bot's turn")
	if (*squares)[4] == " " {
		return 4
	}
	blockableMoves := []uint8{}
	for _, winCondition := range winConditions {
		for vacantPosition := range 3 {
			if ((*squares)[winCondition[vacantPosition]] == " " && (*squares)[winCondition[(vacantPosition+1)%3]] == "X") && (*squares)[winCondition[(vacantPosition+2)%3]] == "X" {
				blockableMoves = append(blockableMoves, winCondition[vacantPosition])
			}
		}
	}
	if len(blockableMoves) == 0 {
		for index, square := range squares {
			if square == " " {
				return uint8(index)
			}
		}
	}
	return blockableMoves[0]
}

func humanPlayer(squares *[9]string, currentPlayer *bool) uint8 {
	var playerMark string = "X"
	if !*currentPlayer {
		playerMark = "O"
	}
	fmt.Printf("Player %s to move [0-8] > ", playerMark)
	var move uint8
	fmt.Scan(&move)
	if move > 8 || (*squares)[move] != " " {
		fmt.Println("Invalid move")
		return humanPlayer(squares, currentPlayer)
	}
	return move
}

func checkWin(playerMark string, squares *[9]string) bool {
	for _, winCondition := range winConditions {
		if (*squares)[winCondition[0]] == playerMark && (*squares)[winCondition[1]] == playerMark && (*squares)[winCondition[2]] == playerMark {
			return true
		}
	}
	return false
}

func main() {

	squares := [9]string{
		" ", " ", " ", " ", " ", " ", " ", " ", " ",
	}
	fmt.Print("\033[H\033[2J")
	currentPlayer := true
	for {
		fmt.Print(createBoard(&squares, boardTemplate))
		var move int8 = -1
		for move == -1 {
			if currentPlayer {
				move = int8(humanPlayer(&squares, &currentPlayer))
			} else {
				move = int8(botPlayer(&squares))
			}
		}
		var playerMark string = "X"
		if !currentPlayer {
			playerMark = "O"
		}

		squares[move] = playerMark

		if checkWin(playerMark, &squares) {
			fmt.Print(createBoard(&squares, boardTemplate))
			fmt.Printf("Player %s wins!\n", playerMark)
			break
		}

		emptySpot := false
		for _, square := range squares {
			if square == " " {
				emptySpot = true
				break
			}
		}
		if !emptySpot {
			fmt.Println("Cat's game!")
			break
		}

		currentPlayer = !currentPlayer

	}
}
