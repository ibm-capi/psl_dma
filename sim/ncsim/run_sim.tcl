set NCSIM_PATH = `pwd`

rm -fr ./work/*

setenv PATH $NCSIM_PATH/../../pslse/afu_driver/src:$NCSIM_PATH/../../pslse/libcxl:$PATH
setenv LD_LIBRARY_PATH $NCSIM_PATH/../../pslse/afu_driver/src:$NCSIM_PATH/../../pslse/libcxl:$LD_LIBRARY_PATH


cd $NCSIM_PATH
ncvlog -64bit -sv ../../pslse/afu_driver/verilog/*.v 
ncvlog -64bit ../../rtl/*.v

ncelab -64bit work.top -access +rwc -timescale 1ns/1ns

ncsim -64bit -tcl work.top -input open_wave.tcl 


