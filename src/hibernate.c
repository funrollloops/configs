#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

const char kStateFile[] = "/sys/power/state";
const char kDisk[] = "disk\n";

bool write_all(int fd, const char* s, int len) {
  while (len != 0) {
    int result = write(fd, s, len);
    if (result <= 0) {
      return false;
    }
    s += result;
    len -= result;
  }
  return true;
}

void print_error() {
  char* s = strerror(errno);
  write_all(1, s, strlen(s));
}

int main(int argc, char* argv[]) {
  int fd = open(kStateFile, O_RDWR | O_TRUNC);
  if (fd < 0) {
    print_error();
    return 1;
  }
  if (!write_all(fd, kDisk, sizeof(kDisk))) {
    return 2;
  }
  close(fd);
  return 0;
}
