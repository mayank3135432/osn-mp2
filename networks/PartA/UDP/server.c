#include "tools.h"

int server_socket, client_sockets[2];
GameState game;

void handle_client_disconnect(int player) {
    close(client_sockets[player]);
    client_sockets[player] = 0;
    printf("Player %d disconnected.\n", player + 1);
}

void send_to_clients(const char *message) {
    for (int i = 0; i < 2; i++) {
        if (client_sockets[i] > 0) {
            send(client_sockets[i], message, strlen(message), 0);
        }
    }
}

void play_game() {
    char buffer[BUFFER_SIZE];
    int game_over = 0;
    while (!game_over) {
        int current_socket = client_sockets[game.current_player];
        sprintf(buffer, "Your turn (Player %d). Enter row and column (1-3 1-3): ", game.current_player + 1);
        send(current_socket, buffer, strlen(buffer), 0);
        int bytes_received = recv(current_socket, buffer, BUFFER_SIZE, 0);
        if (bytes_received <= 0) {
            handle_client_disconnect(game.current_player);
            game_over = 1;
            continue;
        }
        buffer[bytes_received] = '\0';
        int row, col;
        if (sscanf(buffer, "%d %d", &row, &col) != 2 || row < 1 || row > 3 || col < 1 || col > 3) {
            send(current_socket, "Invalid input. Try again.\n", 26, 0);
            continue;
        }
        if (!make_move(&game, row - 1, col - 1)) {
            send(current_socket, "Invalid move. Try again.\n", 25, 0);
            continue;
        }
        print_board(&game);
        char board_str[100];
        sprintf(board_str, "\nCurrent board:\n%c|%c|%c\n-+-+-\n%c|%c|%c\n-+-+-\n%c|%c|%c\n",
                game.board[0][0], game.board[0][1], game.board[0][2],
                game.board[1][0], game.board[1][1], game.board[1][2],
                game.board[2][0], game.board[2][1], game.board[2][2]);
        send_to_clients(board_str);
        int winner = check_winner(&game);
        if (winner != -1) {
            sprintf(buffer, "Player %d wins!\n", winner + 1);
            send_to_clients(buffer);
            game_over = 1;
        } else if (is_board_full(&game)) {
            send_to_clients("It's a draw!\n");
            game_over = 1;
        } else {
            game.current_player = 1 - game.current_player;
        }
    }
}

int main() {
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
    server_socket = socket(AF_INET, SOCK_zzz, 0);
    if (server_socket == -1) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);
    if (bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }
    if (listen(server_socket, 2) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }
    printf("Server listening on port %d\n", PORT);
    while (1) {
        init_board(&game);
        game.current_player = 0;
        for (int i = 0; i < 2; i++) {
            if (client_sockets[i] == 0) {
                client_sockets[i] = accept(server_socket, (struct sockaddr *)&client_addr, &client_len);
                if (client_sockets[i] < 0) {
                    perror("Accept failed");
                    continue;
                }
                printf("Player %d connected\n", i + 1);
                char welcome_msg[50];
                sprintf(welcome_msg, "Welcome, Player %d! You are %c\n", i + 1, (i == 0) ? PLAYER_X : PLAYER_O);
                send(client_sockets[i], welcome_msg, strlen(welcome_msg), 0);
            }
        }
replay:
        printf("WE HAVE LOOOPPEDDD LOOOOP!!!!!\n");
        printf("Current player: %d\n", game.current_player + 1);
        send_to_clients("Both players connected. Game starting!\n");
        play_game();

        // Ask if players want to play again
        char play_again_msg[] = "Do you want to play again? (y/n): ";
        int play_again[2] = {0, 0};

        for (int i = 0; i < 2; i++) {
            if (client_sockets[i] > 0) {
                send(client_sockets[i], play_again_msg, strlen(play_again_msg), 0);
                char response[10];
                int bytes_received = recv(client_sockets[i], response, sizeof(response), 0);
                if (bytes_received > 0) {
                    response[bytes_received] = '\0';
                    play_again[i] = (response[0] == 'y' || response[0] == 'Y');
                }
            }
        }

        if (play_again[0] && play_again[1]) {
            send_to_clients("Both players agreed to play again. Starting a new game!\n");
            init_board(&game); // Reset the game board
            //game.current_player = 0; // Reset the current player
            print_board(&game);
            //printf("LETS LOOOOP!!!!!\n"); --debug line
            goto replay; // Continue the main game loop
        } else {
            for (int i = 0; i < 2; i++) {
                if (client_sockets[i] > 0) {
                    if (play_again[i] && !play_again[1 - i]) {
                        send(client_sockets[i], "Your opponent doesn't want to play again. Closing connection.\n", 62, 0);
                    }
                    close(client_sockets[i]);
                    client_sockets[i] = 0;
                }
            }
            break; // Exit the main game loop
        }
    }
    close(server_socket);
    return 0;
}