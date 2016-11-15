#include <stdio.h>

int sink;

void data_lost_001 ()
{
	char ret;
	short a = 0x80;
	ret = a;/*Tool should detect this line as error*/ /*ERROR:Integer precision lost because of cast*/
        sink = ret;
}


int main(int argc, char** argv)
{

   printf("Value of sink=%d\n", sink);
}
