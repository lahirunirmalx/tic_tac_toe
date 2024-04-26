<?php

$squares = array_fill(0, 9, ' ');
$players = array('X', 'O');
$current_player = 0;

$board = <<<BOARD
      0    1   2
    +---+---+---+      
    | {0} | {1} | {2} |
    +---+---+---+
  3 | {3} | {4} | {5} | 5
    +---+---+---+
    |{6}  | {7} | {8} |
    +---+---+---+
      6    7   8
BOARD;


$win_conditions = array(
  array(0, 1, 2), array(3, 4, 5), array(6, 7, 8),
  array(0, 3, 6), array(1, 4, 7), array(2, 5, 8),
  array(0, 4, 8), array(2, 4, 6)
);

function check_win($player, $squares) {
  global $win_conditions;

  foreach ($win_conditions as $condition) {
    $row = array($squares[$condition[0]], $squares[$condition[1]], $squares[$condition[2]]);
    if (count(array_unique($row)) === 1 && $row[0] === $player) {
      return true;
    }
  }
  return false;
}


function botPlayer($squares)
{
    global $win_conditions;
    // attack middle
    if($squares[4] == ' '){
        return 4;
    }
    $nonBlockedWinningConditions = array ();
    foreach ($win_conditions as $condition) {
        $row = array($squares[$condition[0]], $squares[$condition[1]], $squares[$condition[2]]);
        if (!in_array('O',$row)) {
            $nonBlockedWinningConditions[] = $condition;
        }
    }
    $shouldBlock = array ();
    foreach ($nonBlockedWinningConditions as $condition) {
        if($squares[$condition[0]] == 'X' && $squares[$condition[1]] == 'X'){
            $shouldBlock[] = $condition[2];
        } elseif($squares[$condition[1]] == 'X' && $squares[$condition[2]] == 'X'){
            $shouldBlock[] = $condition[0];
        }elseif ($squares[$condition[0]] == 'X' && $squares[$condition[2]] == 'X'){
            $shouldBlock[] = $condition[1];
        }else{
            foreach ($condition as $c)  {
                if($squares[$condition[$c]] == ' '){
                    $shouldBlock[] = $condition[$c];
                    break;
                }
            }
        }
    }
    $winingStep = array_values(array_unique($shouldBlock));

    foreach ($winingStep as $step) {
        $tempB = $squares;
        $tempB[$step] = 'X';
        if(check_win('X',$tempB)){
            return $step;
        }
    }

    return  $winingStep[0];


}

function formatBoard(array $squares , $board)
{

    for ($i = 0; $i < count($squares); $i++) {
        $board = str_replace("{" . $i . "}", $squares[$i], $board);
    }
    return $board;


}

while (true) {
    echo sprintf("\033\143");
    $boardT = formatBoard($squares , $board);
    echo $boardT ."\n";

  if (check_win($players[$current_player], $squares)) {
    echo "Player {$players[$current_player]} is the winner!\n";
    break;
  }

  // Check for tie
  if (!in_array(' ', $squares)) {
    echo "Cats game!\n";
    break;
  }

  // Get player move
  do {
    $move = readline("Player {$players[$current_player]} to move [0-8] > ");
    if (!is_numeric($move) || $move < 0 || $move > 8 || $squares[$move] !== ' ') {
      echo "Invalid move!\n";
    }
  } while (!is_numeric($move) || $move < 0 || $move > 8 || $squares[$move] !== ' ');

  // Update board and switch players
  $squares[$move] = $players[$current_player];
    if (check_win($players[$current_player], $squares)) {
        echo "Player {$players[$current_player]} is the winner!\n";
        break;
    }
  $current_player = ($current_player + 1) % 2; // Switch player using modulo
  if($current_player){
      $botPlayerMove = botPlayer($squares);

      $squares[$botPlayerMove] = $players[$current_player];
      if (check_win($players[$current_player], $squares)) {
          echo "Player {$players[$current_player]} is the winner!\n";
          break;
      }
      $current_player = ($current_player + 1) % 2; // Switch player using modulo
  }
}
