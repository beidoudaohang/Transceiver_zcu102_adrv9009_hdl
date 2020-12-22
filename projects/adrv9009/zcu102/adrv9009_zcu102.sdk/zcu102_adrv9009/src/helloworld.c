/*
 * Copyright (c) 2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>


#define MAP_SIZE 		0x10000
#define MAP_SIZE_WORD 	0x100
#define BRAM_SIZE  		0x10000
#define VERBOSE			0


void getstatus(unsigned int *pt_ctrl_addr);
int getlastline(FILE *tx_fh)
{
	int temp_val;
	int cnt = 0;

	for( ; fscanf(tx_fh, "%d", &temp_val) != EOF ;)
	{
		cnt++;
	}

	fseek(tx_fh, 0, SEEK_SET);

	return cnt;
}


int main()
{

	int fd;
	unsigned long *pt_tx_addr, *pt_rx_addr;
	unsigned int *pt_ctrl_addr;

	printf("Writing tx bram data\n");


	fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (fd < 0) {
		printf("Error: /dev/mem open failed!\n");
		return -1;
	}
	pt_tx_addr = (unsigned long *)mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0x80010000);
	if (pt_tx_addr == (unsigned long *)-1) {
		printf("Error: mmap failed!\n");
		return -1;
	}

	pt_rx_addr = (unsigned long *)mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0x80020000);
	if (pt_rx_addr == (unsigned long *)-1) {
		printf("Error: mmap failed!\n");
		return -1;
	}

	pt_ctrl_addr = (u_int32_t *)mmap(0, 32, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0x80000000);
	if (pt_ctrl_addr == (u_int32_t *)-1) {
		printf("Error: mmap failed!\n");
		return -1;
	}

	//make temporary pointer and assign to rx_addr.  Set all values in rxbram to zero.
	unsigned long *pt_temp = pt_rx_addr;

	/*for(int i=0; i<8190; i++)
    {
    	*pt_temp = 0;
    	pt_temp = pt_temp + 1;
    }*/

    //open file to write rx bram files too
	FILE *tx_fh = fopen("/home/root/tx_bram.txt","r");
	if(tx_fh == NULL)
	{
		printf("Error opening tx_bram.txt");
		return -1;
	}

    //open file to write rx bram files too
	FILE *rx_fh = fopen("/home/root/rx_bram.txt","w");

	if(rx_fh == NULL)
	{
		printf("Error opening rx_bram.txt");
		return -1;
	}

	int last_val = 0;
	last_val = getlastline(tx_fh);

	getstatus(pt_ctrl_addr);


	int temp_val = 0;

	//Assign values to the txbuffer
	pt_temp = pt_tx_addr;
    for(int i=0; i<8192; i++)
    {

    	if(i < last_val)
    	{
    		fscanf(tx_fh, "%d", &temp_val);
    		//printf("%d\r\n", temp_val);
    		*pt_temp = temp_val;
    	}
    	else
    	{
    		*pt_temp = 0;
    		printf("%d \r\n", i);

    	}

#if VERBOSE
    	printf("Value: 0x%lx Address: 0x%p \r\n", *pt_temp, pt_temp);
#endif
    	pt_temp = pt_temp + 1;
    }

    //assert reset
    //*pt_ctrl_addr = 5;

    getstatus(pt_ctrl_addr);

	//deassert reset
    printf("Deassert Reset\r\n");
	*pt_ctrl_addr = 4;

	getstatus(pt_ctrl_addr);

	//Enable TX/RX Bram
	printf("Enable TX/RX Bram\r\n");
	*pt_ctrl_addr = 0x34;

	getstatus(pt_ctrl_addr);

	printf("Waiting for bit status to change\r\n");
	u_int32_t status = *(u_int32_t *) (pt_ctrl_addr+4);
	u_int32_t bit_status = ((status >> 4) & 0x0F);
	getstatus(pt_ctrl_addr);

	while(status != 0x727)
	{
		status = *(u_int32_t *) (pt_ctrl_addr+4);
		bit_status = ((status >> 4) & 0x0F);
		getstatus(pt_ctrl_addr);
	}

	printf("Bit status changed\r\n");
	status = *(u_int32_t *) (pt_ctrl_addr+4);
	bit_status = ((status >> 4) & 0x0F);
	getstatus(pt_ctrl_addr);

	/*
	printf("Getting RX bram values\r\n");
	pt_temp = pt_rx_addr;
    for(int i=0; i<100; i++)
    {
    	printf("Value: 0x%lx Address: 0x%p \r\n", *pt_temp, (u_int32_t *) (pt_temp - pt_rx_addr));
    	pt_temp = pt_temp + 1;
    }
*/


	fclose(rx_fh);
	fclose(tx_fh);

	munmap(mmap, MAP_SIZE);
	close(fd);
	return 0;

}

void getstatus(unsigned int *pt_ctrl_addr)
{
	//get status 0x10/4 = 4

		printf("0x%x\n\r", *(pt_ctrl_addr+4));
}
