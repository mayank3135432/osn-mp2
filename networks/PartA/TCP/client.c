#include "tools.h"

int main() {
    int sock = 0;
    struct sockaddr_in serv_addr;
    char buffer[BUFFER_SIZE] = {0};

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\n Socket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("\nConnection Failed \n");
        return -1;
    }

    while (1) {
        int bytes_received = recv(sock, buffer, BUFFER_SIZE, 0);
        if (bytes_received <= 0) {
            printf("Server disconnected.\n");
            break;
        }

        buffer[bytes_received] = '\0';
        printf("%s", buffer);

        if (strstr(buffer, "Your turn") != NULL) {
            fgets(buffer, BUFFER_SIZE, stdin);
            send(sock, buffer, strlen(buffer), 0);
        } else if (strstr(buffer, "play again?") != NULL) {
            // printf("really ? what now ??\n"); --debug line
            fgets(buffer, BUFFER_SIZE, stdin);
            send(sock, buffer, strlen(buffer), 0);
            if (buffer[0] != 'y' && buffer[0] != 'Y') {
                printf("Thanks for playing! Goodbye.\n");
                break;
            }
        } else if (strstr(buffer, "Starting a new game!") != NULL) {
            // Reset client state if necessary
            continue;
        }
    }
    // printf("goodbye cruel life\n"); -- debug line
    close(sock);
    return 0;
}