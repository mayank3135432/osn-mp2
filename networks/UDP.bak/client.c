#include "tools.h"

int client_socket;
struct sockaddr_in server_addr;
GameState current_game;
int player_number;

void send_to_server(const Message *msg) {
    sendto(client_socket, msg, sizeof(Message), 0,
           (struct sockaddr *)&server_addr, sizeof(server_addr));
}

void print_game_state(const GameState *game) {
    printf("\nCurrent board:\n");
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

int main() {
    if ((client_socket = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY;

    Message msg = {0};
    send_to_server(&msg);

    while (1) {
        Message received_msg;
        recvfrom(client_socket, &received_msg, sizeof(Message), 0, NULL, NULL);

        switch (received_msg.type) {
            case MSG_GAME_STATE:
                current_game = received_msg.data.game_state;
                print_game_state(&current_game);
                if (current_game.current_player == player_number) {
                    printf("Your turn. Enter row and column (1-3 1-3): ");
                    int row, col;
                    scanf("%d %d", &row, &col);
                    Message move_msg = {.type = MSG_MOVE, .data.move = {row - 1, col - 1}};
                    send_to_server(&move_msg);
                } else {
                    printf("Waiting for opponent's move...\n");
                }
                break;

            case MSG_MOVE:
                if (received_msg.data.move.row == -1) {
                    printf("Invalid move. Try again.\n");
                }
                break;

            case MSG_GAME_OVER:
                print_game_state(&current_game);
                int winner = received_msg.data.game_over.winner;
                if (winner == -1) {
                    printf("It's a draw!\n");
                } else if (winner == player_number) {
                    printf("You win!\n");
                } else {
                    printf("You lose!\n");
                }
                break;

            case MSG_PLAY_AGAIN:
                printf("Do you want to play again? (1 for yes, 0 for no): ");
                int play_again;
                scanf("%d", &play_again);
                Message play_again_msg = {.type = MSG_PLAY_AGAIN, .data.play_again = {play_again}};
                send_to_server(&play_again_msg);
                if (!play_again) {
                    printf("Thanks for playing! Goodbye.\n");
                    close(client_socket);
                    return 0;
                }
                break;
        }
    }

    close(client_socket);
    return 0;
}