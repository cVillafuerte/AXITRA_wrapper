#
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

################## Nothing to be changed below #################
.SUFFIXES: .o .f90
.SUFFIXES: .o .f

.f90.o:	$(INC)
	$(FC) $(FFLAGS) -c $<
	
.f.o:	$(INC)
	$(FC) $(FFLAGS) -c $<
	
clean:
	/bin/rm *.o *.mod

veryclean:
	/bin/rm *.o axitra_force convms_force *.mod

all: axitra convms

axitra :	dimension1.o dimension2.o parameter.o allocateArray.o initdata.o reflect0.o reflect1.o reflect2.o reflect3.o reflect4.o reflect5.o ff0ad.o axitra.o dll2km.o
	$(FC) $(FFLAGS) axitra.o initdata.o reflect0.o reflect1.o reflect2.o reflect3.o reflect4.o reflect5.o ff0ad.o dimension1.o dimension2.o parameter.o allocateArray.o dll2km.o -o axitra_force
	mv axitra_force $(DEST)

convms :	parameter.o fsource.o convm.o fft2cd.o dll2km.o
	$(FC) $(FFLAGS) parameter.o convm.o fft2cd.o fsource.o dll2km.o -o convms_force
	mv convms_force $(DEST)
