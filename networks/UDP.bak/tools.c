#include "tools.h"

void init_board(GameState *game) {
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            game->board[i][j] = EMPTY;
        }
    }
}

void print_board(const GameState *game) {
    printf("\n");
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            printf(" %c ", game->board[i][j]);
            if (j < BOARD_SIZE - 1) printf("|");
        }
        printf("\n");
        if (i < BOARD_SIZE - 1) printf("-----------\n");
    }
    printf("\n");
}

int make_move(GameState *game, int row, int col) {
    if (row < 0 || row >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE || game->board[row][col] != EMPTY) {
        return 0;
    }
    game->board[row][col] = (game->current_player == 0) ? PLAYER_X : PLAYER_O;
    return 1;
}

int check_winner(const GameState* game) {
    char symbol = (game->current_player == 0) ? PLAYER_X : PLAYER_O;

    // Check rows and columns
    for (int i = 0; i < BOARD_SIZE; i++) {
        if ((game->board[i][0] == symbol && game->board[i][1] == symbol && game->board[i][2] == symbol) ||
            (game->board[0][i] == symbol && game->board[1][i] == symbol && game->board[2][i] == symbol)) {
            return game->current_player;
        }
    }

    // Check diagonals
    if ((game->board[0][0] == symbol && game->board[1][1] == symbol && game->board[2][2] == symbol) ||
        (game->board[0][2] == symbol && game->board[1][1] == symbol && game->board[2][0] == symbol)) {
        return game->current_player;
    }

    return -1;
}

int is_board_full(const GameState *game) {
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            if (game->board[i][j] == EMPTY) {
                return 0;
            }
        }
    }
    return 1;
}
