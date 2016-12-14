# Simulation Scripts for Modelsim/Questasim

Steps：
* Set Modelsim environment variables:

```Bash
set path = (<mentor/modelsim/version... or ... altera/version/modelsim_ase>/bin $path)
```

* Get pslse (PSL simulation engine) downloaded:

```Bash
git clone https://github.com/ibm-capi/pslse
```

  "pslse" directory should be parallel to "rtl", "app" and "sim". 
* Go to build pslse:

Modify `pslse/afu_driver/src/Makefile`, to let `VPI_USER_H_DIR=<modelsim_install_path>/include`

```Bash
cd pslse/libcxl
make
cd ../pslse
make
cd ../afu_driver/src
BIT32=y make    #Modelsim runtime maybe 32-bit. Use 'BIT32=y' to enable it. You may have to switch to bash/ksh. 
```

* Update `afu_questa_start.tcl` to include all of the RTL files.

* In terminal window 1, Start simulator
```Bash
cd sim/modelsim
vsim &
source ./afu_questa_start.tcl  #in Modelsim GUI console
comp_afu_example               #in Modelsim GUI console
sim                            #in Modelsim GUI console
run -all                       #in Modelsim GUI console
```

If you update afu_questa_start.tcl in the middle, use `rs` to re-source it in Modlesim GUI. 

* In terminal window 2, Start pslse
```Bash
cd pslse/pslse
./pslse
```

* In terminal window 3, Start app 
```Bash
cd app
make
./tinytest #APP name and arguments
```
* You can run APP in Window3 multiple times. When APP completes and you are not going to run it anymore, go to Window2 and Ctrl-C to terminate PSLSE. Then exit ncsim in Window 1. 
   
* `vsim.wlf` is the saved waveform data.


