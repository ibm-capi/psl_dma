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

#ifndef _PSL_DMA_H_
#define _PSL_DMA_H_

#include "libcxl.h"

#define	VERSION 0x11

#define DEVICE "/dev/cxl/afu0.0d"
#define CACHELINE_BYTES	128
#define MMIO_JOB_ADDR	0x0
#define MMIO_LOCK_ADDR	0x8

#define DEBUG 1

#ifdef DEBUG
	#define DEBUG_LINE() printf("[%s:%s] line=%d\r\n",__FILE__, __func__, __LINE__)
	#define DEBUG_ERR(fmt, args...) printf("\033[46;31m[%s:%d]\033[0m "#fmt" errno=%d, %m\r\n", __func__, __LINE__, ##args, errno, errno)
	#define DEBUG_INFO(fmt, args...) printf(fmt, ##args)
#else
	#define DEBUG_LINE()
	#define DEBUG_ERR(fmt, ...)
	#define DEBUG_INFO(fmt, ...)
#endif


#if 0
static inline uint64_t rte_rdtsc(void)
{
	union {
		uint64_t tsc_64;
		struct {
#if __BYTE_ORDER == __BIG_ENDIAN
			uint32_t hi_32;
			uint32_t lo_32;
#else
			uint32_t lo_32;
			uint32_t hi_32;
#endif
		};
	} tsc;
	uint32_t tmp;

	asm volatile(
		"0:\n"
		"mftbu	 %[hi32]\n"
		"mftb	 %[lo32]\n"
		"mftbu	 %[tmp]\n"
		"cmpw	 %[tmp],%[hi32]\n"
		"bne	 0b\n"
		: [hi32] "=r"(tsc.hi_32), [lo32] "=r"(tsc.lo_32),
		[tmp] "=r"(tmp)
	);
	return tsc.tsc_64;
}
#else
static inline uint64_t rte_rdtsc(void) {return 0;}
#endif

struct wed {
	__u16 volatile status;		// status bits
	__u16 volatile jcounter;	// job counter
	__u32 volatile ret_size;	// returned size (byte)
	__u32 source_size;			// sizeof source (8 byte alignment)
	__u32 result_size;			// sizeof result buffer (8 byte alignment)
	__u8 * source;				// source buffer address (8 byte alignment)
	__u8 * result;				// result buffer address (8 byte alignment)
	__u32 param_s0;				// 32 bit user defined parameter
	__u32 param_s1;				// 32 bit user defined parameter
	__u32 pad [22];				// padding to 128 bytes
};

void * capi_malloc (int size);

int capi_init ();

void capi_close();

int capi_do_job (struct wed * capi_wed);

#endif
