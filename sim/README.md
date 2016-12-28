# Working with PSL simulation engine (pslse)
Having a simulation environment has many benefits:

1. You can start without Power system and FPGA card, you can work on a personal computer with simulator installed.
2. Get confidence before synthesis/place/route your AFU design. 
3. Debug problem with the help of full waveforms, breakpoints and so on.
4. For software part, nothing need to be changed when moving from simulation to real hardware. 

For how to use, see the README in each subdir. 

# Common problem shooting: 
* When running your APP,  `error while loading shared libraries: libcxl.so`: 

Solution: add `<working path>/pslse/libcxl` into your LD_LIBRARY_PATH variable.

* If Simulator tells `AFU Server is waiting for connection on hostname:32769` but pslse is still attempting to connect AFU at 32768:

Solution: modify `pslse/pslse/shim_host.dat` to the same number, i.e, 32769

