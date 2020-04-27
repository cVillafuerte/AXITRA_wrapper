################## PARAMETERS TO MODIFY *********************************

# GFORTRAN compiler
#
FC=gfortran
FFLAGS = -O3 -cpp -fopenmp


#
# Intel ifort compiler (>V15)
#
#FC=ifort
# debug with openmp
#FFLAGS = -g -qopenmp -cpp -assume byterecl 
# debug without openmp
#FFLAGS = -g -cpp -assume byterecl 
#
# run without openmp
#FFLAGS = -O3 -cpp -assume byterecl 
# run with openmp
#FFLAGS = -O3 -cpp -qopenmp -assume byterecl 

DEST=../bin

################## END OF MODIFICATIONS *************************
################## Nothing to be changed below #################
.SUFFIXES: .o .f90
.SUFFIXES: .o .f

.f90.o:	$(INC)
	$(FC) $(FFLAGS) -c $<

all:	axitra_moment convms_moment

OBJ1=dimension1.o dimension2.o parameter.o allocateArray.o initdata.o reflect0.o reflect1.o reflect2.o reflect3.o \
reflect4.o reflect5.o ff0ad.o dll2km.o axitra.o
OBJ2=dll2km.o dimension1.o dimension2.o parameter.o fft2cd.o fsource.o convm.o
#######################################
#			AXITRA
#######################################

axitra_moment:	$(INC) $(OBJ1)
	$(FC) $(FFLAGS) -o $(DEST)/$@ $(OBJ1) 

######################################
#			CONVM
######################################

convms_moment: $(INC) $(OBJ2)
	$(FC) $(FFLAGS) -o $(DEST)/$@ $(OBJ2)

######################################
#			CLEAN, TAR, ...
######################################
clean: 
	- $(RM) *.o *.mod *.a axitra_moment convms_moment 2>/dev/null

tar:	
	tar cvf axitra.tar * ;gzip axitra.tar\

