# psl_dma
A block DMA engine works with IBM CAPI interface.

rtl :
	A folder with an example to use the DAM engine. The loop_back module get data from DAM engine and loop-back the data to DAM engine.

app :
	A folder with APIs and also a testbench to use the block DMA engine.
    The libcxl is needed to compile the app. Please check it out from https://github.com/ibm-capi/libcxl.git
    Edit Makefile and point the LIBCXL_LIB to the libcxl folder.
