(defpackage :tic-tac-toe
  (:use :cl)
  (:export :main))

(in-package :tic-tac-toe)

(defparameter +board-size+ 9)
(defparameter +board-template+
  "       0     1     2
    +-----+-----+-----+
    | {0} | {1} | {2} |
    +-----+-----+-----+
  3 | {3} | {4} | {5} | 5
    +-----+-----+-----+
    | {6} | {7} | {8} |
    +-----+-----+-----+
       6     7     8
")

(defun create-board (board template)
  (let ((output (copy-seq template)))
    (loop for i from 0 below +board-size+ do
          (let ((token (format nil "{~d}" i)))
            (loop for j from 0 below (length output) do
                  (when (and (= (char output j) #\{)
                             (= (char output (+ j 1)) (char (format nil "~d" i) 0))
                             (= (char output (+ j 2)) #\}))
                    (setf (char output j) (aref board i))
                    (setf (char output (+ j 1)) #\space)
                    (setf (char output (+ j 2)) #\space)))))
    output))

(defun check-win (player board)
  (let ((win-conditions '((0 1 2) (3 4 5) (6 7 8)
                          (0 3 6) (1 4 7) (2 5 8)
                          (0 4 8) (2 4 6))))
    (some (lambda (condition)
            (and (char= (aref board (first condition)) player)
                 (char= (aref board (second condition)) player)
                 (char= (aref board (third condition)) player)))
          win-conditions)))

(defun bot-player (board)
  (let ((win-conditions '((0 1 2) (3 4 5) (6 7 8)
                          (0 3 6) (1 4 7) (2 5 8)
                          (0 4 8) (2 4 6))))
    (if (char= (aref board 4) #\space)
        4
        (let ((blockable-moves (make-array +board-size+ :initial-element nil))
              (blockable-index 0))
          (dolist (condition win-conditions)
            (let ((x-count 0) (empty-index -1))
              (dolist (j condition)
                (cond ((char= (aref board j) #\X)
                       (incf x-count))
                      ((char= (aref board j) #\space)
                       (setf empty-index j))))
              (when (and (= x-count 2) (not (eql empty-index -1)))
                (return-from bot-player empty-index))
              (when (and (= x-count 1) (not (eql empty-index -1)))
                (setf (aref blockable-moves blockable-index) empty-index)
                (incf blockable-index))))
          (aref blockable-moves 0)))))

(defun main ()
  (let ((squares (make-array +board-size+ :initial-element #\space))
        (players (vector #\X #\O))
        (current-player 0)
        (formatted-board (make-array 1024 :initial-element #\space)))
    (loop
       (format t "~C" #\U001B[2J) ; Clear the console
       (setf formatted-board (create-board squares +board-template+))
       (format t "~A~%" formatted-board)

       (when (check-win (aref players current-player) squares)
         (format t "Player ~C is the winner!~%" (aref players current-player))
         (return-from main))

       (unless (some (lambda (c) (char= c #\space)) squares)
         (format t "Cat's game!~%")
         (return-from main))

       (let ((move -1))
         (if (= current-player 0)
             (loop
                (format t "Player ~C to move [0-8] > " (aref players current-player))
                (let ((input (read-line)))
                  (if (and (every #'digit-char-p input)
                           (setq move (parse-integer input :junk-allowed t))
                           (<= 0 move 8)
                           (char= (aref squares move) #\space))
                      (return)
                      (format t "Invalid move!~%"))))
             (setf move (bot-player squares)))

         (setf (aref squares move) (aref players current-player))
         (when (check-win (aref players current-player) squares)
           (format t "Player ~C is the winner!~%" (aref players current-player))
           (return-from main))

         (setf current-player (mod (1+ current-player) 2))))))
