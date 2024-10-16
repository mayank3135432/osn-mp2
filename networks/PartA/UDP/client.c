#include "tools.h"

int main() {
    int sock = 0;
    struct sockaddr_in serv_addr;
    char buffer[BUFFER_SIZE] = {0};
    socklen_t addr_len = sizeof(serv_addr);

    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        printf("\n Socket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    while (1) {
        int bytes_received = recvfrom(sock, buffer, BUFFER_SIZE, 0, (struct sockaddr *)&serv_addr, &addr_len);
        if (bytes_received <= 0) {
            printf("Server disconnected.\n");
            break;
        }
        buffer[bytes_received] = '\0';
        printf("%s", buffer);

        if (strstr(buffer, "Your turn") != NULL) {
            fgets(buffer, BUFFER_SIZE, stdin);
            sendto(sock, buffer, strlen(buffer), 0, (struct sockaddr *)&serv_addr, addr_len);
        } else if (strstr(buffer, "play again?") != NULL) {
            fgets(buffer, BUFFER_SIZE, stdin);
            sendto(sock, buffer, strlen(buffer), 0, (struct sockaddr *)&serv_addr, addr_len);
            if (buffer[0] != 'y' && buffer[0] != 'Y') {
                printf("Thanks for playing! Goodbye.\n");
                break;
            }
        } else if (strstr(buffer, "Starting a new game!") != NULL) {
            // Reset client state if necessary
            continue;
        }
    }

    close(sock);
    return 0;
}