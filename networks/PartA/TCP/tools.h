#ifndef TOOLS_H
#define TOOLS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define PORT 8080
#define BUFFER_SIZE 1024

#define BOARD_SIZE 3
#define EMPTY ' '
#define PLAYER_X 'X'
#define PLAYER_O 'O'

typedef struct {
    char board[BOARD_SIZE][BOARD_SIZE];
    int current_player;
} GameState;

#endif // TOOLS_H
void init_board(GameState *game);
void print_board(const GameState *game);
int make_move(GameState *game, int row, int col);
int check_winner(const GameState *game);
int is_board_full(const GameState *game);

