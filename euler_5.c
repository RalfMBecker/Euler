#include <stdio.h>
#include <stdlib.h>

int lcmA(int*);
int lcm(int, int);

int main(int argc, char* argv[])
{
    int* intArr = malloc(argc * sizeof(int));

    int i;
    for (i = 0; i < argc-1; i++)
	intArr[i] = atol(argv[i+1]);
    intArr[argc-1] = 0;

    printf("The lcm of ( ");
    for (i = 0; i < argc-1; i++)
	printf("%d ", intArr[i]);
    printf(") is:\n\t%d\n", lcmA(intArr));

    return 0;
}


