#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080

void print_board(char board[3][3]) {
    printf("\n");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            printf(" %c ", board[i][j]);
            if (j < 2) printf("|");
        }
        printf("\n");
        if (i < 2) printf("---+---+---\n");
    }
}

int main() {
    struct sockaddr_in serv_addr;
    int sock = 0, valread;
    char board[3][3];
    char buffer[1024] = {0};

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\nSocket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    // Convert IPv4 and IPv6 addresses from text to binary form
    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("\nConnection Failed \n");
        return -1;
    }

    while (1) {
        // Display the board received from the server
        print_board(board);

        // Enter the row and column for the move
        int row, col;
        printf("Enter your move (row and column): ");
        scanf("%d %d", &row, &col);

        // Send the move to the server
        sprintf(buffer, "%d %d", row, col);
        send(sock, buffer, strlen(buffer), 0);
        printf("Move sent\n");

        // Logic to receive board updates and check for game over
    }

    close(sock);
    return 0;
}
