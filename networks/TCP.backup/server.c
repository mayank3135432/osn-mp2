#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define MAX 3

char board[MAX][MAX];
int currentPlayer = 1;

void initializeBoard() {
    for (int i = 0; i < MAX; i++) {
        for (int j = 0; j < MAX; j++) {
            board[i][j] = ' ';
        }
    }
}

void printBoard() {
    for (int i = 0; i < MAX; i++) {
        for (int j = 0; j < MAX; j++) {
            printf("%c ", board[i][j]);
            if (j < MAX - 1) printf("| ");
        }
        printf("\n");
        if (i < MAX - 1) printf("---------\n");
    }
}

int checkWin() {
    // Check rows and columns
    for (int i = 0; i < MAX; i++) {
        if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != ' ')
            return 1;
        if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != ' ')
            return 1;
    }
    // Check diagonals
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != ' ')
        return 1;
    if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != ' ')
        return 1;
    return 0;
}

int checkDraw() {
    for (int i = 0; i < MAX; i++) {
        for (int j = 0; j < MAX; j++) {
            if (board[i][j] == ' ')
                return 0;
        }
    }
    return 1;
}

void sendBoard(int client1, int client2) {
    char buffer[1024];
    memset(buffer, 0, sizeof(buffer));
    for (int i = 0; i < MAX; i++) {
        for (int j = 0; j < MAX; j++) {
            buffer[i * MAX + j] = board[i][j];
        }
    }
    send(client1, buffer, sizeof(buffer), 0);
    send(client2, buffer, sizeof(buffer), 0);
}

void handleClient(int client1, int client2) {
    int row, col;
    char buffer[1024];
    send(client1, "Hello idiot. You are X\n", 15, 0);
    while (1) {
        memset(buffer, 0, sizeof(buffer));
        if (currentPlayer == 1) {
            send(client1, "Your turn (X): ", 15, 0);
            recv(client1, buffer, sizeof(buffer), 0);
        } else {
            send(client2, "Your turn (O): ", 15, 0);
            recv(client2, buffer, sizeof(buffer), 0);
        }
        sscanf(buffer, "%d %d", &row, &col);
        if (row >= 0 && row < MAX && col >= 0 && col < MAX && board[row][col] == ' ') {
            board[row][col] = (currentPlayer == 1) ? 'X' : 'O';
            if (checkWin()) {
                sendBoard(client1, client2);
                if (currentPlayer == 1) {
                    send(client1, "Player 1 Wins!\n", 15, 0);
                    send(client2, "Player 1 Wins!\n", 15, 0);
                } else {
                    send(client1, "Player 2 Wins!\n", 15, 0);
                    send(client2, "Player 2 Wins!\n", 15, 0);
                }
                break;
            }
            if (checkDraw()) {
                sendBoard(client1, client2);
                send(client1, "It's a Draw!\n", 13, 0);
                send(client2, "It's a Draw!\n", 13, 0);
                break;
            }
            currentPlayer = (currentPlayer == 1) ? 2 : 1;
            sendBoard(client1, client2);
        } else {
            if (currentPlayer == 1) {
                send(client1, "Invalid move, try again.\n", 25, 0);
            } else {
                send(client2, "Invalid move, try again.\n", 25, 0);
            }
        }
    }
}

int main() {
    int server_fd, client1, client2;
    struct sockaddr_in address;
    int addrlen = sizeof(address);

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen");
        close(server_fd);
        exit(EXIT_FAILURE);
    }

    printf("Waiting for players to connect...\n");

    if ((client1 = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
        perror("accept");
        close(server_fd);
        exit(EXIT_FAILURE);
    }
    printf("Player 1 connected.\n");

    if ((client2 = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
        perror("accept");
        close(server_fd);
        exit(EXIT_FAILURE);
    }
    printf("Player 2 connected.\n");

    initializeBoard();
    sendBoard(client1, client2);
    handleClient(client1, client2);

    close(client1);
    close(client2);
    close(server_fd);
    return 0;
}