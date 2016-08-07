# (c) Copyright International Business Machines 2014

# this is the location of the Power Service Layer Simulation Engine libcxl
# this example assumes you've extracted the demo in the same directory in which you
# extracted the PSLSE
LIBCXL_DIR=./libcxl
OBJ_DIR=.

CFLAGS += -O2 -Wall -m64
LIBCFLAGS += -O2 -Wall -m64
#CFLAGS += -g -Wall -m64
#LIBCFLAGS += -g -Wall -m64 -DDEBUG
PSL_FLAGS= $(LIBCFLAGS) -I$(PSL_DIR)
APP=tinytest

all: ${APP}

${APP} : ${APP}.c
	${CC} ${APP}.c psl_dma.c -o $@ ${CFLAGS} -L${PWD} -L${LIBCXL_DIR} -I${PWD} -I${LIBCXL_DIR} -lm -lcxl -lpthread -lrt

shim_host.dat:
	$(error 'Please symlink shim_host.dat ususally from ./pslse-master/pslse/shim_host.dat')

clean:
	/bin/rm -f ${APP} *.a $(OBJ_DIR)/*.o
