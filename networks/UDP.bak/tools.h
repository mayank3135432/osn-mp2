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

typedef struct {
    struct sockaddr_in addr;
    int player_number;
} ClientInfo;

// Message types
#define MSG_MOVE 1
#define MSG_GAME_STATE 2
#define MSG_GAME_OVER 3
#define MSG_PLAY_AGAIN 4

typedef struct {
    int type;
    union {
        struct { int row; int col; } move;
        GameState game_state;
        struct { int winner; } game_over;
        struct { int play_again; } play_again;
    } data;
} Message;

void init_board(GameState *game);
void print_board(const GameState *game);
int make_move(GameState *game, int row, int col);
int check_winner(const GameState *game);
int is_board_full(const GameState *game);

#endif // TOOLS_H