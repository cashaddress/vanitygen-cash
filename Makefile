LIBS=-lpcre -lcrypto -lm -lpthread
CFLAGS=-ggdb -Wall
OBJS=vanitygen.o oclvanitygen.o oclvanityminer.o oclengine.o keyconv.o pattern.o util.o cashaddr.o
PROGS=vanitygen keyconv oclvanitygen oclvanityminer
# OPTIMIZE
# -O0 = no optimization
# -O3 = good optimization
# -Ofast = aggressive optimization
# -Os = small file size
CFLAGS+=-O0
CXXFLAGS+=-O0

PLATFORM=$(shell uname -s)
ifeq ($(PLATFORM),Darwin)
	ifneq ($(wildcard /usr/local/Cellar/gcc/7.3.0/bin/*),)
		CC=/usr/local/Cellar/gcc/7.3.0/bin/g++-7
		CXX=/usr/local/Cellar/gcc/7.3.0/bin/g++-7
	else
		# support for Xcode/clang
		CC=g++
		CXX=g++
		CFLAGS+=-std=c++14
		CXXFLAGS+=-std=c++14
	endif
	#ifneq ($(wildcard /usr/local/opt/openssl@1.1/lib/*),)
	#	LIBS+=-L/usr/local/opt/openssl@1.1/lib
	#	CFLAGS+=-I/usr/local/opt/openssl@1.1/include
	#else
		LIBS+=-L/usr/local/opt/openssl/lib
		CFLAGS+=-I/usr/local/opt/openssl/include
	#endif
	OPENCL_LIBS=-framework OpenCL
	LIBS+=-L/usr/local/opt/pcre/lib
	CFLAGS+=-I/usr/local/opt/pcre/include
	# Below 2 lines add support for MacPorts
	LIBS+=-L/opt/local/lib
	CFLAGS+=-I/opt/local/include
else
	CC=g++-7
	CXX=g++-7
	OPENCL_LIBS=-lOpenCL
endif

most: vanitygen

all: $(PROGS)

vanitygen: vanitygen.o pattern.o util.o cashaddr.o
	$(CC) $^ -o $@ $(CFLAGS) $(LIBS)

oclvanitygen: oclvanitygen.o oclengine.o pattern.o util.o cashaddr.o
	$(CC) $^ -o $@ $(CFLAGS) $(LIBS) $(OPENCL_LIBS)

oclvanityminer: oclvanityminer.o oclengine.o pattern.o util.o cashaddr.o
	$(CC) $^ -o $@ $(CFLAGS) $(LIBS) $(OPENCL_LIBS) -lcurl

keyconv: keyconv.o util.o cashaddr.o
	$(CC) $^ -o $@ $(CFLAGS) $(LIBS)

clean:
	./cleanup.command
