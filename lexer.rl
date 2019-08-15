#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

%%{

  machine test_lexer;

  spaces = " "+;
  words  = (^" ")+; # Can be alnum+

  main := |*
    words  => { count ++; };
    spaces => { /* nothing here */ };
  *|;

}%%

int run( char * str, unsigned int len) {
    int count = 0;

    // Various variables, which will be used by Ragel generated code
    // below.
    char *p = str,
         *pe = str + len,
         *eof = pe;
    char *ts, *te; // token start, token end.
    int cs, act;   // Variables, internally required by scanner.

    %% write data;
    %% write init;
    %% write exec;

    return count;
}

// Below is just a function main and mmap-helper functions.
size_t get_file_size(const char* filename)
{
    struct stat st;
    stat(filename, &st);
    return st.st_size;
}

int main(int argc, char ** argv) {
    if( argc < 2) {
        perror("Please give name of the file...");
        return -1;
    }

    int fd = open(argv[1], O_RDONLY, 0);

    assert(fd != -1);

    size_t filesize = get_file_size(argv[1]);
    void* mmappedData = mmap((caddr_t)0, filesize, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
    assert(mmappedData != MAP_FAILED);

    // Parsing from mmapped file
    printf("%d\n", run((char*)mmappedData, filesize));

    int rc = munmap(mmappedData, filesize);
    assert(rc == 0);
    close(fd);

    return 0;
}
