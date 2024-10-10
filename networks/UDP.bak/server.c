#include "tools.h"

int server_socket;
GameState game;
ClientInfo clients[2];
int num_clients = 0;

void send_to_client(const ClientInfo *client, const Message *msg) {
    sendto(server_socket, msg, sizeof(Message), 0,
           (struct sockaddr *)&client->addr, sizeof(client->addr));
}

void send_to_clients(const Message *msg) {
    for (int i = 0; i < num_clients; i++) {
        send_to_client(&clients[i], msg);
    }
}

void send_game_state() {
    Message msg;
    msg.type = MSG_GAME_STATE;
    msg.data.game_state = game;
    send_to_clients(&msg);
}

void handle_move(int player, int row, int col) {
    if (player != game.current_player || !make_move(&game, row, col)) {
        Message msg = {.type = MSG_MOVE, .data.move = {-1, -1}};
        send_to_client(&clients[player], &msg);
        return;
    }

    print_board(&game);
    send_game_state();

    int winner = check_winner(&game);
    if (winner != -1 || is_board_full(&game)) {
        Message msg = {.type = MSG_GAME_OVER, .data.game_over = {winner}};
        send_to_clients(&msg);
    } else {
        game.current_player = 1 - game.current_player;
    }
}

int main() {
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);

    server_socket = socket(AF_INET, SOCK_DGRAM, 0);
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

    printf("Server listening on port %d\n", PORT);

    while (1) {
        init_board(&game);
        game.current_player = 0;
        num_clients = 0;

        while (num_clients < 2) {
            Message msg;
            recvfrom(server_socket, &msg, sizeof(Message), 0, (struct sockaddr *)&client_addr, &client_len);
            
            if (num_clients == 0 || memcmp(&client_addr, &clients[0].addr, sizeof(client_addr)) != 0) {
                clients[num_clients].addr = client_addr;
                clients[num_clients].player_number = num_clients;
                
                msg.type = MSG_GAME_STATE;
                msg.data.game_state = game;
                send_to_client(&clients[num_clients], &msg);
                
                num_clients++;
                printf("Player %d connected\n", num_clients);
            }
        }

        printf("Both players connected. Game starting!\n");
        send_game_state();

        int game_over = 0;
        while (!game_over) {
            Message msg;
            recvfrom(server_socket, &msg, sizeof(Message), 0,
                     (struct sockaddr *)&client_addr, &client_len);

            int player = -1;
            for (int i = 0; i < 2; i++) {
                if (memcmp(&client_addr, &clients[i].addr, sizeof(client_addr)) == 0) {
                    player = i;
                    break;
                }
            }

            if (player == -1) continue;

            switch (msg.type) {
                case MSG_MOVE:
                    handle_move(player, msg.data.move.row, msg.data.move.col);
                    break;
                case MSG_GAME_OVER:
                    game_over = 1;
                    break;
            }
        }

        // Ask if players want to play again
        Message play_again_msg = {.type = MSG_PLAY_AGAIN};
        send_to_clients(&play_again_msg);

        int play_again[2] = {0, 0};
        for (int i = 0; i < 2; i++) {
            Message response;
            recvfrom(server_socket, &response, sizeof(Message), 0,
                     (struct sockaddr *)&client_addr, &client_len);
            if (response.type == MSG_PLAY_AGAIN) {
                play_again[i] = response.data.play_again.play_again;
            }
        }

        if (!play_again[0] || !play_again[1]) {
            break;
        }
    }

    close(server_socket);
    return 0;
}