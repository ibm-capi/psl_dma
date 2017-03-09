# psl_dma
A block DMA engine works with IBM CAPI interface.

* rtl :
	A folder with an example to use the DMA engine.
    The loop_back module get data from DMA engine and loop-back the data to DMA engine.

* app :
	A folder with APIs and also a testbench to use the block DMA engine.

    The libcxl is needed to compile the app. Please check it out from https://github.com/ibm-capi/libcxl.git
    Edit Makefile and point the LIBCXL_LIB to the libcxl folder.

* sim :
        Example simulation scripts for Modelsim/VCS/NCSim

# web links

* PSL (Processor Service Layer) interface protocol: http://openpowerfoundation.org/wp-content/uploads/resources/psl-afu-spec/content/go01.html

* CAPI homepage: https://www-304.ibm.com/webapp/set2/sas/f/capi/home.html, go to Nallatech or Alphadata website (on the right bar `Purchase CAPI Development Kit`) to learn the information of FPGA cards, and CAPI user guide on Altera/Xilinx edition. 
