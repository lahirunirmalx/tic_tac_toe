use std::io::{self, Write};

const BOARD_SIZE: usize = 9;

fn create_board(board: &[char; BOARD_SIZE], template: &str, output: &mut String) {
    *output = template.to_string();
    for i in 0..BOARD_SIZE {
        let token = format!("{{{}}}", i);
        *output = output.replace(&token, &board[i].to_string());
    }
}

fn check_win(player: char, board: &[char; BOARD_SIZE]) -> bool {
    let win_conditions = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ];

    for condition in win_conditions.iter() {
        if board[condition[0]] == player &&
           board[condition[1]] == player &&
           board[condition[2]] == player {
            return true;
        }
    }
    false
}

fn bot_player(board: &[char; BOARD_SIZE]) -> usize {
    let win_conditions = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ];

    if board[4] == ' ' {
        return 4; // Middle move
    }

    let mut blockable_moves = Vec::new();

    for condition in win_conditions.iter() {
        let mut x_count = 0;
        let mut empty_index = None;
        for &index in condition.iter() {
            if board[index] == 'X' {
                x_count += 1;
            } else if board[index] == ' ' {
                empty_index = Some(index);
            }
        }

        if x_count == 2 {
            if let Some(index) = empty_index {
                return index; // Block winning move
            }
        }

        if x_count == 1 {
            if let Some(index) = empty_index {
                blockable_moves.push(index); // Record potential move
            }
        }
    }

    // Return the first valid move
    blockable_moves[0]
}

fn main() {
    let board_template = 
        "       0     1     2\n\
         +-----+-----+-----+\n\
         | {0} | {1} | {2} |\n\
         +-----+-----+-----+\n\
       3 | {3} | {4} | {5} | 5\n\
         +-----+-----+-----+\n\
         | {6} | {7} | {8} |\n\
         +-----+-----+-----+\n\
            6     7     8\n";

    let mut squares = [' '; BOARD_SIZE];
    let players = ['X', 'O'];
    let mut current_player = 0;
    let mut formatted_board = String::new();

    loop {
        print!("\x1B[2J\x1B[1;1H"); // Clear the console
        create_board(&squares, board_template, &mut formatted_board);
        println!("{}", formatted_board);

        if check_win(players[current_player], &squares) {
            println!("Player {} is the winner!", players[current_player]);
            break;
        }

        if !squares.contains(&' ') {
            println!("Cat's game!");
            break;
        }

        let move_index = if current_player == 0 {
            loop {
                print!("Player {} to move [0-8] > ", players[current_player]);
                io::stdout().flush().unwrap();

                let mut input = String::new();
                io::stdin().read_line(&mut input).unwrap();
                if let Ok(move_index) = input.trim().parse::<usize>() {
                    if move_index < BOARD_SIZE && squares[move_index] == ' ' {
                        break move_index;
                    }
                }
                println!("Invalid move!");
            }
        } else {
            bot_player(&squares)
        };

        squares[move_index] = players[current_player];

        if check_win(players[current_player], &squares) {
            println!("Player {} is the winner!", players[current_player]);
            break;
        }

        current_player = (current_player + 1) % 2;
    }
}
