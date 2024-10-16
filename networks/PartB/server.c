#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <fcntl.h>

#define MAX_BUFFER 1024
#define CHUNK_SIZE 100
#define PORT 8888
#define TIMEOUT_MS 100

typedef struct {
    int seq_num;
    int total_chunks;
    char data[CHUNK_SIZE];
} Packet;

typedef struct {
    int ack_num;
} Ack;

void send_message(int sockfd, struct sockaddr_in *addr, socklen_t addr_len, const char *message) {
    Packet send_packet;
    Ack ack_packet;
    int msg_len = strlen(message);
    int flags = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);
    int total_chunks = (msg_len + CHUNK_SIZE - 1) / CHUNK_SIZE;

    for (int i = 0; i < total_chunks; i++) {
        send_packet.seq_num = i + 1;
        send_packet.total_chunks = total_chunks;
        strncpy(send_packet.data, message + i * CHUNK_SIZE, CHUNK_SIZE);

        int attempts = 0;
        int ack_received = 0;

        while (!ack_received && attempts < 5) {
            sendto(sockfd, &send_packet, sizeof(Packet), 0,
                   (const struct sockaddr *)addr, addr_len);
            printf("Sent chunk %d of %d\n", send_packet.seq_num, send_packet.total_chunks);

            struct timeval tv;
            tv.tv_sec = 0;
            tv.tv_usec = TIMEOUT_MS * 1000;

            fd_set readfds;
            FD_ZERO(&readfds);
            FD_SET(sockfd, &readfds);


            int activity = select(sockfd + 1, &readfds, NULL, NULL, &tv);

            if (activity > 0 && FD_ISSET(sockfd, &readfds)) {
                recvfrom(sockfd, &ack_packet, sizeof(Ack), 0, NULL, NULL);
                if (ack_packet.ack_num == send_packet.seq_num) {
                    printf("Received ACK for chunk %d\n", ack_packet.ack_num);
                    ack_received = 1;
                }
            } else {
                printf("Timeout, retransmitting chunk %d\n", send_packet.seq_num);
                attempts++;
            }
        }

        if (!ack_received) {
            printf("Failed to send chunk %d after 5 attempts\n", send_packet.seq_num);
        }
    }
}

char* receive_message(int sockfd, struct sockaddr_in *addr, socklen_t *addr_len) {
    Packet received_packet;
    Ack ack_packet;
    char *received_data = NULL;
    int total_chunks = 0;
    int received_chunks = 0;
    int message_count = 0;

    while (received_chunks < total_chunks || total_chunks == 0) {
        int recv_len = recvfrom(sockfd, &received_packet, sizeof(Packet), 0,
                                (struct sockaddr *)addr, addr_len);

        if (recv_len > 0) {
            printf("Received chunk %d of %d\n", received_packet.seq_num, received_packet.total_chunks);
            message_count++;
            // Send ACK
            if (message_count % 3 != 0 | 1){
                ack_packet.ack_num = received_packet.seq_num;
                sendto(sockfd, &ack_packet, sizeof(Ack), 0, (const struct sockaddr *)addr, *addr_len);
            }else {
                printf("Skipping ACK for chunk %d\n", received_packet.seq_num);
            }
            // Process received data
            if (received_data == NULL) {
                total_chunks = received_packet.total_chunks;
                received_data = calloc(total_chunks * CHUNK_SIZE + 1, sizeof(char));
            }

            memcpy(received_data + (received_packet.seq_num - 1) * CHUNK_SIZE,
                   received_packet.data, CHUNK_SIZE);
            received_chunks++;
        }

        // Small delay to prevent busy-waiting
        usleep(1000);
    }

    received_data[total_chunks * CHUNK_SIZE] = '\0';
    return received_data;
}

int main() {
    int sockfd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t addr_len = sizeof(client_addr);
    char buffer[MAX_BUFFER];

    // Create UDP socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&server_addr, 0, sizeof(server_addr));
    memset(&client_addr, 0, sizeof(client_addr));

    // Server information
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    // Bind socket
    if (bind(sockfd, (const struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    printf("Server listening on port %d...\n", PORT);

    // Set socket to non-blocking mode
    int flags = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

    while (1) {
        char *received_message = receive_message(sockfd, &client_addr, &addr_len);
        if (received_message != NULL) {
            printf("Received message: %s\n", received_message);
            free(received_message);

            printf("Enter your response: ");
            fgets(buffer, MAX_BUFFER, stdin);
            buffer[strcspn(buffer, "\n")] = 0; // Remove newline

            send_message(sockfd, &client_addr, addr_len, buffer);
        }

        // Small delay to prevent busy-waiting
        usleep(1000);
    }

    close(sockfd);
    return 0;
}