# Simulation Scripts for Synopsys VCS

Steps：

* Set VCS environment variables:

```Bash
setenv VCS_HOME <Where_you_installed_VCS/version>
if (-e ${VCS_HOME}/bin/environ.csh) then
  source ${VCS_HOME}/bin/environ.csh
endif
```

* Get pslse (PSL simulation engine) downloaded:

```
git clone https://github.com/ibm-capi/pslse
```

"pslse" directory should be parallel to "rtl", "app" and "sim".

* Go to build pslse:
Modify `pslse/afu_driver/src/Makefile`
let `VPI_USER_H_DIR=${VCS_HOME}/include`

```Bash
cd pslse/libcxl
make
cd ../pslse
make
cd ../afu_driver/src
make
```

* Update `sim/vcs/filelist` to include all of the RTL files.

* Edit `pslse/afu_driver/verilog/top.v`, add following if you want to dump VCD waveform:
```Verilog
initial begin 
  $vcdpluson (0, top.a0);
end
```
* Edit `pslse/vcs_include`, at line1 and line3:
```Bash
-CFLAGS '-I<Absolute_path_to>/pslse/common'
-CFLAGS '-I$VCS_HOME/`vcs -platform`/lib'
-P <Absolute_or_Relative_path_to>/pslse/afu_driver/verilog/top.tab
```
Please ensure line1 and line3 are pointing to the correct path. 
Use absolute path if pslse is placed at a common place. 


* In terminal window 1, Start simulator
```Bash
cd sim/vcs
./run.sh
./simv
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
If it cannot find libcxl.so, set $LD_LIBRARY_PATH to `<PSLSE PATH>/pslse/libcxl`

* You can run APP in Window3 multiple times. When APP completes and you are not going to run it anymore, go to Window2 and Ctrl-C to terminate PSLSE. Then exit ncsim in Window 1.

Use `dve` to open `vcdplus.vpd` to view the waveform. 
