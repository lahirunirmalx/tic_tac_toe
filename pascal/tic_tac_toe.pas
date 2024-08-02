program TicTacToe;

uses
  crt, sysutils;

const
  BOARD_SIZE = 9;
  WIN_CONDITIONS: array[0..7, 0..2] of Integer = (
    (0, 1, 2), (3, 4, 5), (6, 7, 8),
    (0, 3, 6), (1, 4, 7), (2, 5, 8),
    (0, 4, 8), (2, 4, 6)
  );

type
  TBoard = array[0..BOARD_SIZE-1] of Char;

procedure CreateBoard(const board: TBoard; const template: String; var output: String);
var
  i, j: Integer;
  token: String;
begin
  output := template;
  for i := 0 to BOARD_SIZE - 1 do
  begin
    token := Format('{%d}', [i]);
    j := Pos(token, output);
    while j > 0 do
    begin
      output[j] := board[i];
      output[j + 1] := ' ';
      output[j + 2] := ' ';
      j := Pos(token, output);
    end;
  end;
end;

function CheckWin(player: Char; const board: TBoard): Boolean;
var
  i: Integer;
begin
  for i := 0 to 7 do
  begin
    if (board[WIN_CONDITIONS[i][0]] = player) and
       (board[WIN_CONDITIONS[i][1]] = player) and
       (board[WIN_CONDITIONS[i][2]] = player) then
    begin
      CheckWin := True;
      Exit;
    end;
  end;
  CheckWin := False;
end;

function BotPlayer(const board: TBoard): Integer;
var
  i, j, xCount, emptyIndex: Integer;
  blockableMoves: array[0..BOARD_SIZE-1] of Integer;
  blockableIndex: Integer;
begin
  if board[4] = ' ' then
  begin
    BotPlayer := 4;
    Exit;
  end;

  blockableIndex := 0;

  for i := 0 to 7 do
  begin
    xCount := 0;
    emptyIndex := -1;
    for j := 0 to 2 do
    begin
      if board[WIN_CONDITIONS[i][j]] = 'X' then
        Inc(xCount)
      else if board[WIN_CONDITIONS[i][j]] = ' ' then
        emptyIndex := WIN_CONDITIONS[i][j];
    end;

    if (xCount = 2) and (emptyIndex <> -1) then
    begin
      BotPlayer := emptyIndex;
      Exit;
    end;

    if (xCount = 1) and (emptyIndex <> -1) then
    begin
      blockableMoves[blockableIndex] := emptyIndex;
      Inc(blockableIndex);
    end;
  end;

  BotPlayer := blockableMoves[0];
end;

var
  boardTemplate, formattedBoard: String;
  squares: TBoard;
  players: array[0..1] of Char;
  currentPlayer, i, move: Integer;
  hasEmptySpot: Boolean;

begin
  boardTemplate := 
    '       0     1     2'#13#10 +
    '    +-----+-----+-----+'#13#10 +
    '    | {0} | {1} | {2} |'#13#10 +
    '    +-----+-----+-----+'#13#10 +
    '  3 | {3} | {4} | {5} | 5'#13#10 +
    '    +-----+-----+-----+'#13#10 +
    '    | {6} | {7} | {8} |'#13#10 +
    '    +-----+-----+-----+'#13#10 +
    '       6     7     8'#13#10;

  for i := 0 to BOARD_SIZE - 1 do
    squares[i] := ' ';

  players[0] := 'X';
  players[1] := 'O';
  currentPlayer := 0;

  while True do
  begin
    ClrScr;
    CreateBoard(squares, boardTemplate, formattedBoard);
    WriteLn(formattedBoard);

    if CheckWin(players[currentPlayer], squares) then
    begin
      WriteLn('Player ', players[currentPlayer], ' is the winner!');
      Break;
    end;

    hasEmptySpot := False;
    for i := 0 to BOARD_SIZE - 1 do
      if squares[i] = ' ' then
        hasEmptySpot := True;

    if not hasEmptySpot then
    begin
      WriteLn('Cat''s game!');
      Break;
    end;

    move := -1;
    if currentPlayer = 0 then
    begin
      repeat
        Write('Player ', players[currentPlayer], ' to move [0-8] > ');
        ReadLn(move);
        if (move < 0) or (move > 8) or (squares[move] <> ' ') then
        begin
          WriteLn('Invalid move!');
          move := -1;
        end;
      until move <> -1;
    end
    else
      move := BotPlayer(squares);

    squares[move] := players[currentPlayer];

    if CheckWin(players[currentPlayer], squares) then
    begin
      WriteLn('Player ', players[currentPlayer], ' is the winner!');
      Break;
    end;

    currentPlayer := (currentPlayer + 1) mod 2;
  end;
end.
