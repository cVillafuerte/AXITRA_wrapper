!******************************************************************************
!*             AXITRA Moment Version
!
!*             PROGRAMME AXITRA
!*
!*           Calcul de sismogrammes synthetiques en milieu stratifie a symetrie
!*      cylindrique.
!*        Propagation par la methode de la reflectivite, avec coordonnees
!*      cylindriques (r, theta, z)
!*      Attenuation sur les ondes P et S
!*
!*      auteur : Olivier Coutant
!*        Bibliographie :
!*                      Kennett GJRAS vol57, pp557R, 1979
!*                        Bouchon JGR vol71, n4, pp959, 1981
!*
!******************************************************************************

program axitra

   use dimension1
   use dimension2
   use parameter
   use initdatam
   use reflect0m
   use reflect1m
   use reflect2m
   use reflect3m
   use reflect4m
   use reflect5m
   use allocatearraym

! the following works with intel compiler
! it may be necessary to remove it and explicitely declare instead
! integer :: omp_get_num_threads, omp_get_thread_num
#if defined(_OPENMP)
   use omp_lib
#endif

   implicit none
! Local
   character(len=50)   :: sourcefile, statfile, dirout
   integer             :: ic, ir, is, nfreq, ikmax, ncp, iklast, jf, ik, lastik, source_opt, seism_opt
   integer             :: nrs ! number of receiver radial distance
   integer             :: ncr ! number of layer containing a receiver
   integer             :: ncs ! number of layer containing a source

   integer              :: nr, ns, nc
   real(kind=8)         :: dfreq, freq, pil
   logical              :: latlon, freesurface
   logical, allocatable :: tconv(:, :)
   real(kind=8)         :: rw, aw, phi, zom, tl, xl, t0, t1
   namelist/input/nc, nfreq, tl, aw, nr, ns, xl, ikmax, latlon, freesurface, source_opt, t0, t1, &
                  sourcefile, statfile, dirout, seism_opt

#include "version.h"
   write(0,*) 'running axitra '//VERSION


!++++++++++
!           LECTURE DES PARAMETRES D ENTREE
!
!               sismogramme : nfreq,tl,xl
!               recepteurs  : nr,xr(),yr(),zr()
!               source      : xs,ys,zs
!               modele      : nc,hc(),vp(),vs(),rho()
!
!               si hc(1)=0 on donne les profondeurs des interfaces, sinon
!               on donne les epaisseurs des couches
!++++++++++

   open (in1, form='formatted', file='axi.data')
   open (out, form='formatted', file='axi.head')
   rewind (out)

   read (in1, input)
   if (freesurface) then
      write(6,*) '................. with a free surface at depth Z=0'
   else
      write(6,*) '................. with no free surface'
   endif

   call allocateArray1(nc, nr, ns)

   do ic = 1, nc
      read (in1, *) hc(ic), vp(ic), vs(ic), rho(ic), qp(ic), qs(ic)
   enddo
   open (in2, form='formatted', file=sourcefile)
   open (in3, form='formatted', file=statfile)

! We assume here that record length is given in byte.
! For intel compiler, it means using "assume byterecl" option
! record length is 6 x (complex double precision) = 6 x 2 x 8 bytes
   open (out2, access='direct', recl=6*3*2*8*nr*ns, form='unformatted',file='axi.res')


!
!++++++++++
!           INITIALISATIONS
!++++++++++

   call initdata(latlon, nr, ns, nc, ncr, ncs,nrs)

   allocate (jj0(nkmax, nrs))
   allocate (jj1(nkmax, nrs))

   uconv = rerr*rerr
   dfreq = 1./tl
   aw = -pi*aw/tl
   pil = pi2/xl
   iklast = 0

!$OMP PARALLEL DEFAULT(FIRSTPRIVATE) &
!$OMP SHARED(dfreq,iklast,nc,nr,ns,ncs,ncr,uconv) &
!$OMP SHARED(tl,aw,pil,cff,jj0,jj1)
#if defined(_OPENMP)
   if (omp_get_thread_num()==1) then
       write(0,*) 'running openMp on ',omp_get_num_threads(),' threads'
   endif
#endif
   call allocateArray2(nc, nr, ns,nrs)
   allocate (tconv(nr, ns))

!               ***************************
!               ***************************
!               **  BOUCLE EN FREQUENCE  **
!               ***************************
!               ***************************

!$OMP DO ORDERED,SCHEDULE(DYNAMIC)
   do jf = 1, nfreq
      freq = (jf - 1)*dfreq
!      write (6, *) 'freq', jf, '/', nfreq
      rw = pi2*freq
      omega = cmplx(rw, aw)
      omega2 = omega*omega
      a1 = .5/omega2/xl
      zom = sqrt(rw*rw + aw*aw)
      if (jf .eq. 1) then
         phi = -pi/2
      else
         phi = atan(aw/rw)
      endif
      do ir = 1, nr
         do is = 1, ns
            tconv(ir, is) = .false.
         enddo
      enddo

      ttconv = .false.
      xlnf = (ai*phi + dlog(zom))/pi
! Futterman
      xlnf = (ai*phi + dlog(zom/(pi2*fref)))
! Kjartansson
      xlnf = zom/(pi2*fref)

!            ******************************************
!            ******************************************
!            **  RESOLUTION PAR BOUCLE EXTERNE EN Kr **
!            ******************************************
!            ******************************************

      do ik = 0, ikmax

         kr = (ik + .258)*pil
         kr2 = kr*kr

!+++++++++++++
!              Calcul de nombreux coefficients et des fonctions de Bessel
!+++++++++++++

         call reflect0(ik + 1, iklast, nc, nr,ns, nrs)

!+++++++++++++
!              Calcul des coefficients de reflexion/transmission
!               Matrice de Reflection/Transmission et Dephasage
!+++++++++++++

         call reflect1(freesurface, nc)

!+++++++++++++
!              Calcul des matrices de reflectivite : mt(),mb(),nt(),nb()
!              (rapport des differents potentiels montant/descendant
!                        en haut et en bas de chaque couche)
!+++++++++++++

         call reflect2(nc)

!+++++++++++++
!               Calcul des matrices de passage des vecteurs potentiel
!                source, aux vecteurs potentiel PHI, PSI et KHI au sommet
!                de chaque couche
!+++++++++++++
         call reflect3(ncs)

!+++++++++++++
!               Calcul des potentiels et des deplacement dus aux sources du
!                tenseur, en chaque recepteur (termes en kr, r, z)
!+++++++++++++
         call reflect4(jf, ik, ik .gt. ikmin, tconv, nc, nr, ns, ncs, ncr)

         if (ttconv) exit

      end do !wavenumber loop

!+++++++++++++
!               Calcul des deplacements aux recepteurs
!                Sortie des resultats
!+++++++++++++

      lastik = ik - 1
      write (out, *) 'freq =', freq, 'iter =', lastik
      write (6,"(1a1,'freq ',I5,'/',I5,' iter=',I5,$)") char(13),jf, nfreq,lastik

      if (jf .eq. 1) lastik = 0

      call reflect5(jf, nr, ns)

      if (ik .ge. ikmax) then
         write (0, *) 'Depassement du nombre d iteration maximum'
         stop
      endif

   enddo !boucle freq
!$OMP END PARALLEL
   write(6,*) 'Done'
   stop
end
