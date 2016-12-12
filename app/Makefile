# (c) Copyright International Business Machines 2014

# this is the location of the Power Service Layer Simulation Engine libcxl
# this example assumes you've extracted the demo in the same directory in which you
# extracted the PSLSE
PSLSE_DIR=../pslse/libcxl
COMM_DIR=../pslse/common
OBJ_DIR=.

CFLAGS += -O2 -Wall -m64
LIBCFLAGS += -O2 -Wall -m64
#CFLAGS += -g -Wall -m64
#LIBCFLAGS += -g -Wall -m64 -DDEBUG
PSL_FLAGS= $(LIBCFLAGS) -I$(PSL_DIR)
APP=tinytest

all: ${APP}

${APP} : ${APP}.c
	${CC} ${APP}.c psl_dma.c -o $@ ${CFLAGS} -L${PWD} -L${PSLSE_DIR} -I${PWD} -I${PSLSE_DIR} -I${COMM_DIR} -lm -lcxl -lpthread -lrt

clean:
	/bin/rm -f ${APP} *.a $(OBJ_DIR)/*.o
