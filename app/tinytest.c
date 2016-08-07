/*
 i Copyright 2014 International Business Machines
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *	   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <errno.h>
#include <getopt.h>
#include <linux/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <sys/types.h>

#include "psl_dma.h"

int input_size = 8*1024*1024;
int output_size = 8*1024*1024;

//#define xilinx	1


void print_help ()
{
	printf( "Usage: command [-i:o:]\n" );
	printf("\t-i : down stream buffer size (byte).\n");
	printf("\t-o :   up stream buffer size (byte).\n");
	exit (0);
}

void verify_clock ()
{
	unsigned long start_cnt, end_cnt;
	struct timespec start, now, ts;
	double time_passed;
	printf ("\n\t#### Verifying the clock counter ...\n");
	ts.tv_sec = 0;
	ts.tv_nsec = 100000;

	if (clock_gettime(CLOCK_REALTIME, &start) == -1) {
		perror("clock_gettime");
		return;
	}
	start_cnt = rte_rdtsc();
	nanosleep(&ts, &ts);
	end_cnt = rte_rdtsc ();
	if (clock_gettime(CLOCK_REALTIME, &now) == -1) {
		perror("clock_gettime");
		return;
	}
	time_passed = (now.tv_sec - start.tv_sec) +
				(double)(now.tv_nsec - start.tv_nsec) /
				(double)(1000000000L);

	printf ("\ttime passed %lf sec, counter time = %ld ns\n", time_passed, (end_cnt-start_cnt)<<1);
	printf ("\t#### Verifying the clock counter done.\n\n");
}

void gen_random_content (__u8 * source_buf)
{
	int i;

	//srand ((int)time(NULL));

	for (i = 0; i < input_size; i ++)
		source_buf [i] = i;//rand();
}


void verify_result (__u8 * source_buf, __u8 * result_buf)
{
	int cmp_size;

	cmp_size = (input_size > output_size) ? output_size : input_size;

	if (memcmp (source_buf, result_buf, cmp_size)) {
		printf ("The up stream data is not the same as down stream data.\n");
	}
}



int main (int argc, char **argv)
{
	int opt;
	int ret;
	__u8 * source_buf, * result_buf;
	__u8 * source_buf_orig, * result_buf_orig;
	struct wed * capi_wed;
	unsigned long start_cnt, end_cnt;
	double bw, job_sec;

	input_size = rand()%1024 + 1;
	output_size = rand()%16 + input_size;

	while ((opt = getopt(argc, argv, "i:o:")) != -1) {
		switch(opt)
		{
			case 'i' :
				input_size = atoi (optarg);
				break;

			case 'o' :
				output_size = atoi (optarg);
				break;

			default :
				print_help ();
				break;
		}
	}

	source_buf_orig = capi_malloc (input_size+128);
	result_buf_orig = capi_malloc (output_size+128);
	memset (source_buf_orig, 0, input_size+128);
	memset (result_buf_orig, 0, input_size+128);

	// Ramdonly simulate the non cache align address
	source_buf = source_buf_orig + (rand()%16)*8;
	result_buf = result_buf_orig + (rand()%16)*8;
	gen_random_content (source_buf);

	capi_wed = capi_malloc (CACHELINE_BYTES);
	if (capi_wed == NULL) {
		printf ("Can not allocate memory for DAM WED.\n");
		return -1;
	}
	verify_clock ();

	capi_wed->source_size = input_size;
	capi_wed->result_size = output_size;
	capi_wed->source = source_buf;
	capi_wed->result = result_buf;


	ret = capi_init ();
	if (ret) {
		printf ("CAPI device init error.\n");
		return -1;
	}
	printf ("\t#### Open CAPI device Done.\n\n");

	start_cnt = rte_rdtsc();
	ret = capi_do_job (capi_wed);
	end_cnt = rte_rdtsc();

	if (ret) {
		printf ("Job can not be finished.\n");
		capi_close ();
		printf ("\t#### Close CAPI device Done.\n\n");

		return -1;
	}

	printf ("\t#### Finish the computation.\n\n");

	job_sec = ((double)((end_cnt-start_cnt)<<1))/1000000000.0;
	bw = ((double)input_size)/job_sec/1024/1024;
	printf ("%f ses. bw = %f MB/s\n", job_sec, bw);

	printf ("\n\t#### Verifying the result...\n\n");
	verify_result (source_buf, result_buf);

	capi_close ();
	printf ("\t#### Close CAPI device Done.\n\n");

	return 0;
}
