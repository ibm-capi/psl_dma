# Simulation Scripts for Cadence IES (ncsim)

Steps：
* Set IES environment variables:

```Bash
setenv CDS_INST_DIR <Where_you_installed_Incisiv/version>
set path = ($CDS_INST_DIR/tools/bin $path)
```

* Get pslse (PSL simulation engine) downloaded:

```Bash
git clone https://github.com/ibm-capi/pslse
```

  "pslse" directory should be parallel to "rtl", "app" and "sim". 
* Go to build pslse:

```Bash
cd pslse
cd libcxl
make
cd ../pslse
make
cd ../afu_driver/src
make
```

If needed, double check `pslse/afu_driver/src/Makefile`, where `VPI_USER_H_DIR=$(CDS_INST_DIR)/tools/include`

* Update `sim/ncsim/run_sim.tcl` to include all of the RTL files.

* In terminal window 1, Start simulator
```Bash
cd sim/ncsim
source run_sim.tcl
run
```

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
   
* Use `simvision` to open wave.shm to view the waveform. Edit `open_wave.tcl` for waveform settings.


# Problem shooting: 
* When running your APP, see `error while loading shared libraries: libcxl.so`: 

Solution: add `<working path>/pslse/libcxl` into your LD_LIBRARY_PATH variable.

* If ncsim run tells `AFU Server is waiting for connection on hostname:32769` but pslse is still attempting to connect AFU at 32768:

Solution: modify `pslse/pslse/shim_host.dat` to the same number, i.e, 32769


