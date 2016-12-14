
# Common problem shooting: 
* When running your APP,  `error while loading shared libraries: libcxl.so`: 

Solution: add `<working path>/pslse/libcxl` into your LD_LIBRARY_PATH variable.

* If Simulator tells `AFU Server is waiting for connection on hostname:32769` but pslse is still attempting to connect AFU at 32768:

Solution: modify `pslse/pslse/shim_host.dat` to the same number, i.e, 32769

