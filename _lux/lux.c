#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <errno.h>
#include <dirent.h>
#include <libgen.h>

#define NUM_STEPS 100

typedef struct {
    char *path;
    int max_b;
    int b;
} Controller;

void write_b(Controller *controller, int new_b) {
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "sudo tee %s/brightness", controller->path);
    FILE *pfile = popen(cmd, "w");
    if (pfile) {
        fprintf(pfile, "%d", new_b);
        fclose(pfile);
    }
}

void notify(Controller *controller) {
    char perc[32];
    snprintf(perc, sizeof(perc), "int:value:%.2f", (controller->b * 100.0) / controller->max_b);
    char command[512];
    char *basename_path = basename(controller->path);
    snprintf(command, sizeof(command), "notify-send %s -h %s -h string:synchronous:volume", basename_path, perc);
    system(command);
}

Controller* best_controller(const char *start_path) {
    DIR *dir;
    struct dirent *entry;
    Controller *best_c = NULL;
    char c_path[256];
    int best_max = 0;

    if ((dir = opendir(start_path)) != NULL) {
        while ((entry = readdir(dir)) != NULL) {
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
                char max_b_path[256];
                snprintf(max_b_path, sizeof(max_b_path), "%s/%s/max_brightness", start_path, entry->d_name);
                FILE *file = fopen(max_b_path, "r");
                if (file) {
                    int max_b;
                    fscanf(file, "%d", &max_b);
                    fclose(file);
                    if (max_b > best_max) {
                        best_max = max_b;
                        best_c = malloc(sizeof(Controller));
                        
                        snprintf(c_path, sizeof(c_path), "%s/%s", start_path, entry->d_name);
                        best_c->path = strdup(c_path);
                        best_c->max_b = max_b;
                        char brightness_path[256];
                        snprintf(brightness_path, sizeof(brightness_path), "%s/%s/brightness", start_path, entry->d_name);
                        file = fopen(brightness_path, "r");
                        if (file) {
                            fscanf(file, "%d", &best_c->b);
                            fclose(file);
                        }
                    }
                }
            }
        }
        closedir(dir);
    }
    return best_c;
}

void bail() {
    fprintf(stderr, "pass me 'up' or 'down'\n");
    exit(1);
}

int main(int argc, char *argv[]) {
    int s;
    struct sockaddr_un addr;

    s = socket(AF_UNIX, SOCK_STREAM, 0);
    if (s < 0) {
        exit(0);
    }

    memset(&addr, 0, sizeof(struct sockaddr_un));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, "\0lux_lock", sizeof(addr.sun_path) - 1);
    if (bind(s, (struct sockaddr *)&addr, sizeof(struct sockaddr_un)) < 0) {
        exit(0);
    }

    if (argc < 2) {
        bail();
    }

    char *mode = argv[1];
    if (strcmp(mode, "up") != 0 && strcmp(mode, "down") != 0) {
        bail();
    }

    Controller *controller = best_controller("/sys/class/backlight");
    if (controller == NULL) {
        return 0;
    }

    int n = round(NUM_STEPS * log(fmax(1, controller->b)) / log(controller->max_b));
    int new_b = controller->b;

    if (strcmp(mode, "up") == 0 && controller->b < controller->max_b) {
        int new_n = n;
        while (new_b <= controller->b) {
            new_n += 1;
            new_b = (int)pow(controller->max_b, (double)new_n / NUM_STEPS);
        }
    }
    if (strcmp(mode, "down") == 0 && controller->b > 0) {
        int new_n = n;
        while (new_b >= controller->b) {
            new_n -= 1;
            new_b = (int)pow(controller->max_b, (double)new_n / NUM_STEPS);
        }
    }
    new_b = fmax(0, fmin(new_b, controller->max_b));
    write_b(controller, new_b);
    notify(controller);

    free(controller->path);
    free(controller);
    return 0;
}
