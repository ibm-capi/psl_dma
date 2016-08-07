/*
 * Copyright 2014 International Business Machines
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
#include "libcxl.h"

struct cxl_afu_h * afu_h = NULL;

inline int capi_try_lock ()
{
	uint64_t ret;
	cxl_mmio_read64 (afu_h, MMIO_LOCK_ADDR, &ret);
	return (uint32_t) ret;
}

inline void capi_unlock ()
{
	cxl_mmio_write64 (afu_h, MMIO_LOCK_ADDR, 0UL);
}

void * capi_malloc (int size)
{
	int ret;
	void * buf;

	ret = posix_memalign (&buf, CACHELINE_BYTES, size);
	if (ret)
		return NULL;
	else
		return buf;
}

int capi_init ()
{
	uint64_t ret;
	char cxl_device [64];

	strncpy (cxl_device, DEVICE, 64);
/*	
	for (ret = 0; ret < 8; ret ++) {
		if (access(cxl_device, W_OK) == 0)
			break;

		cxl_device [12] ++;
	}

	if (ret == 8) {
		printf ("Can not find available CAPI device.\n");
		return -1;
	}
*/
	afu_h = cxl_afu_open_dev (cxl_device);
	if (!afu_h) {
		printf ("Open device \"%s\" fail.\n", cxl_device);
		return -1;
	}
	DEBUG_INFO ("Open device %s\n", cxl_device);

	cxl_afu_attach (afu_h, 0xff60UL);
//	if ((cxl_mmio_map (afu_h, CXL_MMIO_FLAGS_AFU_BIG_ENDIAN)) < 0) {
	if ((cxl_mmio_map (afu_h, CXL_MMIO_BIG_ENDIAN)) < 0) {
		printf ("Can not map MMIO registers.\n");
		cxl_afu_free (afu_h);
		afu_h = NULL;
		return -1;
	}
	DEBUG_INFO ("Mmap MMIO register done.\n");

	cxl_mmio_read64 (afu_h, MMIO_JOB_ADDR, &ret);
	DEBUG_INFO ("Get device init status 0x%lx.\n", ret);
	
	if (((ret & 0xff00) >> 8) != VERSION) {
		printf ("The library do not match the hardware version.\n");
		printf ("Software Version : %02x; Hardware Version : %02lx\n", VERSION, ((ret & 0xff00) >> 8));
		cxl_mmio_write64 (afu_h, MMIO_JOB_ADDR, 0UL);
		cxl_mmio_unmap (afu_h);
		cxl_afu_free (afu_h);
		afu_h = NULL;
		return -1;
	}

	return 0;
}

void capi_close()
{
	if (!afu_h)
		return;
	cxl_mmio_write64 (afu_h, MMIO_JOB_ADDR, 0UL);
	cxl_mmio_unmap (afu_h);
	cxl_afu_free (afu_h);
	afu_h = NULL;
}


int	capi_do_job (struct wed * capi_wed)
{
	int i;
	unsigned long start_cnt, end_cnt;

	if (afu_h == NULL)
		if (capi_init ())
			return -1;

	if ((long)(capi_wed) & 0x7fUL) {
		printf ("Error. The CAPI WED address is not 128 byte alignment.\n");
		return -1;
	}

	if (((long)(capi_wed->source) & 0x7UL) || ((long)(capi_wed->result) & 0x7UL)) {
		printf ("Error. The CAPI DMA buffer address is not 8 byte alignment.\n");
		return -1;
	}

	DEBUG_INFO ("Attach wed address 0x%p\n", capi_wed);

	capi_wed->status = 0;
	capi_wed->ret_size = 0;

	cxl_mmio_write64 (afu_h, MMIO_JOB_ADDR, (__u64) capi_wed);
	cxl_mmio_write64 (afu_h, MMIO_JOB_ADDR + 16, (__u64) capi_wed);

	DEBUG_INFO ("Waiting job finish ...\n");
	start_cnt = rte_rdtsc();
	while (!capi_wed->status) {
		end_cnt = rte_rdtsc();
		if ((end_cnt - start_cnt) > 1000000000UL) {	// More than 0.5 sec
			printf ("Erasure encode time out. Please resume application to reset the hardware.\n");
			return -1;
		}
		for (i = 0; i <= 100; i ++)
			;
	}
	DEBUG_INFO ("Job finish. Size = 0x%x\n", capi_wed->ret_size);

	return 0;
}

