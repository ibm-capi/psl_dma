# (c) Copyright International Business Machines 2014

#catch [quit -sim]

set print echo
$print "----------------------------------------"
$print "  rs                      - Re-Source startup file "
$print "  comp_afu_example        - Compile memcopy example "
$print "  sim                     - Start vsim"
$print "----------------------------------------"


proc rs {} {source afu_questa_start.tcl}
proc g {} {go}

proc logall {} {
    log -r sim:/test_bench/*
}

proc comp_afu_example {} {
    
    set print echo
    set PATH_AFU_SRC {../../rtl}
    set PATH_TOP_SRC {../../pslse/afu_driver/verilog}
    set DEFINES "+define"

	vlib work
	vmap work work
    $print " Compiling afu example "

    # Compile System Verilog Test Bench (Linux Pipes to PSL Shim via DPI)
    $print "Work Library:  TB --> Compiling top verilog"
    vlog \
	$PATH_TOP_SRC/top.v \
		-sv \
        +notimingchecks
            
    # Compiling memcpy vhdl example
    $print "Work Library:  DUT --> Compiling PSL_DMA verilog example"
    vlog \
             $PATH_AFU_SRC/afu.v \
             $PATH_AFU_SRC/parity.v \
             $PATH_AFU_SRC/mmio.v \
             $PATH_AFU_SRC/endian_swap.v \
             $PATH_AFU_SRC/tx_align.v \
             $PATH_AFU_SRC/rx_align.v \
             $PATH_AFU_SRC/loop_back.v \
             $PATH_AFU_SRC/BRAM_WRAPPER.v \
             $PATH_AFU_SRC/SYNC_FIFO_WRAPPER.v \
             -novopt \
			 -sv \
             -time 

    exec vmake > makefile.tb
    $print "Makefile Generated"
}



# Simulate Testbench
proc sim {} {
    set print echo
    $print " Start sim "

    #vsim -t ps +nowarnTSCALE  -L work_altera 
    #vsim -t ps +nowarnTSCALE work.slite2sam_interface_tb -L work_altera
    #vsim -t ps -novopt -c +nowarnTSCALE work.top -L work_altera_verilog
	#vsim -t ns -novopt -c -pli ../../pslse/afu_driver/src/veriuser.sl +nowarnTSCALE work.top
    vsim -t ns -novopt -c -sv_lib ../../pslse/afu_driver/src/libdpi +nowarnTSCALE work.top
    view wave
    radix h
    log * -r
    do wave.do
    view structure
    view signals
    $print "SIM Started"
    #run -all
}


proc g {} {do go.do}

