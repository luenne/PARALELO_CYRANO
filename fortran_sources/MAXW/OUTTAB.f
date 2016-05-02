      subroutine OUTTAB
      USE GLOBAL
      implicit none
C
C     WRITE EQUILIBRIUM TABLES TO FILES
c	NB : The (R,Z) grid for the 2D OUTPUT was already built and
c	     written to Rcyr.dat and Zcyr.dat in subroutine OUTGRID.f.
c		 All relevant variables are passed from OUTGRID through 
c		 COMMONS (nploth, polplo, istp(ireg), ist11, intaplot, )

C-------------------------------------------------------------------------------

      include 'pardim.copy'
      include 'comgeo.copy'
      include 'commag.copy'
      include 'comfin.copy'
      include 'compla.copy'
      include 'complo.copy'
      include 'complp.copy'
      include 'comphy.copy'
      include 'coequi.copy'
      include 'comant.copy'
      include 'comreg.copy'
      include 'mpif.h'
c      include 'paralelo.copy'

	character(120) :: GGs
	integer :: j, ipo, aux 

c     cccccccccccccccc Writing equilibrium TABLES to file ccccccccccccccccc

c    	1) Plasma profiles (for all species) [1D] --------------------------
 
	GGs  = "(g16.6," // char(nspec+48) // "g16.6)"

      if(.not. glovac)then

c     1.1) Species temperature	
      if (rank .eq. 0) then
	     open (UNIT = 777, FILE = paplda // 'temperatures.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
         write(777,*), 'Species temperature profiles'
         write(777,*), 'nspec', ' rad ', ' pla ' 		
	     write(777,"(i6, i5, i5)"), nspec, nabsci, i_rp
         write(777,*), 'rho(m) ', paname(1:nspec)
	     do j = 1 , nabsci
		    write ( 777, GGs ), abscis(j), temtab(j,1:nspec)
	     end do
	     close(777)	
	
c     1.2) Species density	
	     open (UNIT = 777, FILE = paplda // 'densities.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
	     write(777,*), 'Species density profiles'
	     write(777,*), 'nspec', ' rad ', ' pla ' 		
	     write(777,"(i6, i5, i5)"), nspec, nabsci, i_rp
	     write(777,*), 'rho(m) ', paname(1:nspec)
	     do j = 1, nabsci
		    write ( 777, GGs ), abscis(j), dentab(j,1:nspec)
	     end do
	     close(777)	

c     1.3) Species thermal velocity	
	     open (UNIT = 777, FILE = paplda // 'vthermal.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
	     write(777,*), 'Thermal velocity profiles'
	     write(777,*), 'nspec', ' rad ', ' pla ' 		
	     write(777,"(i6, i5, i5)"), nspec, nabsci, i_rp
	     write(777,*), 'rho(m) ', paname(1:nspec)
	     do j = 1, nabsci
		    write ( 777, GGs ), abscis(j), vttab(j,1:nspec)
	     end do
	     close(777)
      end if ! (rank .eq. 0)
	end if	! (NOT glovac)

c     2) General 1D quantities  ------------------------------------------

c     2.1) Safety factor
      if (rank .eq. 0) then
        open (UNIT = 777, FILE = paplda // 'qprof.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
        write(777,*), 'Safety factor'
        write(777,*), ' rad ', ' pla ' 		
        write(777,"(i5, i5)"), nabsci, i_rp
        write(777,*), 'rho(m)', ' q '
        do j = 1, nabsci
	        write(777,"(g16.6, g16.6)"), abscis(j) , qfactor(j)
        end do
        close(777)	

c     2.2) Poloidal flux Psi	
        open (UNIT = 777, FILE = paplda // 'psifunc.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
        write(777,*), 'Poloidal flux Psi'
        write(777,*), ' rad ', ' pla ' 		
        write(777,"(i5, i5)"), nabsci, i_rp
        write(777,*), 'rho(m)', ' Psi '
        do j = 1, nabsci
	        write(777,"(g16.6, g16.6)"), abscis(j) , eqta1d(j,7)
        end do
        close(777)

c     2.3) Poloidal flux derivative (not normalized) dPsi/dr	
        open (UNIT = 777, FILE = paplda // 'dpsidr_n.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
        write(777,*), 'Poloidal flux derivative dPsi/dr'
        write(777,*), ' rad ', ' pla ' 		
        write(777,"(i5, i5)"), nabsci, i_rp
        write(777,*), 'rho(m)', ' dPsi/dr '
        do j = 1, nabsci
	        write(777,"(g16.6, g16.6)"), abscis(j) , dPsidr_n(j)*abscis(j)
        end do
        close(777)	

c     2.4) Surface perimeter	
        open (UNIT = 777, FILE = paplda // 'perimeter.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
        write(777,*), 'Surface perimeter'
        write(777,*), ' rad ', ' pla ' 		
        write(777,"(i5, i5)"), nabsci, i_rp
        write(777,*), 'rho(m)', ' perimeter(m) '
        do j = 1,nabsci
            write(777,"(g16.6, g16.6)"), abscno(j) , surf_perim(j)
        end do
        close(777)	

c     2.5) Major radius at Z=Zmag
        open (UNIT = 777, FILE = paplda // 'major_rad.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
        write(777,*), 'Major radius at Z=Zmag'
        write(777,*), ' rad ', ' pla ' 		
        write(777,"(i5, i5)"), nabsci, i_rp
        write(777,*), 'rho(m)', ' R(m) '
        do j = 1, nabsci	
	        write(777,"(g16.6, g16.6)"), abscis(j), eqt(j,1,1)
        end do
        close(777)
      end if ! (rank .eq. 0)
c     2.6) H coefficient (COKPCO)
      if(cokpco .and. rank .eq. 0)then
	     open (UNIT = 777, FILE = paplda // 'Hcoef.dat', 
     ;         STATUS = "REPLACE", ACTION = "WRITE")
         write(777,*), 'H coefficient (cokpco)'
	     write(777,*), ' rad ' , ' pla ' 
	     write(777,"(i5, i5)"), nabsci, i_rp 
         do j = 1, nabsci
            write(777,2222), abscis(j), 1/hachi(j)
         end do
         close(777)
	end if ! (cokpco)  and (rank .eq. 0)

cERN	08/03/05 : New quantities exported

c     2.7) Plasma current I(rho)
       if (rank .eq. 0) then
	      open (UNIT = 777, FILE = paplda // 'Irho.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
          write(777,*), 'Plasma current I(rho)'
          write(777,*), ' rad ', ' pla ' 		
          write(777,"(i5, i5)"), nabsci, i_rp
          write(777,*), 'rho(m)', ' Ip(A) '
          do j = 1, nabsci	
	         write(777,"(g16.6, g16.6)"), abscis(j), eqta1d(j,3)*abscis(j)*abscis(j)
          end do
	      close(777)

c     2.8) Lambda(rho) = 1/(2pi) int[Ntheta^2/(R.J) dthteta]
	      open (UNIT = 777, FILE = paplda // 'lambda.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
          write(777,*), 'Lambda(rho) = 1/(2pi) int[Ntheta^2/(R.J) dthteta]'
          write(777,*), ' rad ', ' pla ' 		
          write(777,"(i5, i5)"), nabsci, i_rp
          write(777,*), 'rho(m)', ' lambda '
          do j = 1, nabsci	
	         write(777,"(g16.6, g16.6)"), abscis(j), eqta1d(j,5)*abscis(j)
          end do
	      close(777)

c     2.9) Elongation 
	      open (UNIT = 777, FILE = paplda // 'kappa.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
          write(777,*), 'Elongation kappa'
          write(777,*), ' rad ', ' pla ' 		
          write(777,"(i5, i5)"), nabsci, i_rp
          write(777,*), 'rho(m)', ' kappa '
          do j = 1, nabsci	
	         write(777,"(g16.6, g16.6)"), abscis(j), kappa_tab(j)
          end do
	      close(777)
      end if ! (rank .eq. 0)

c     3) General 2D quantities  ------------------------------------------
c	   NB: The (R,Z) grid routines for PLOTTING were already written 
c	       in OUTGRID.f to Rcyr.dat and Zcyr.dat
c		   FORMAT: (ist11) lines vs. (nploth+1) columns
c	       (if OUTGAU = T, ist11 = nabsci and nploth = npfft)

	if(plot2D)then

c     3.1) Pitch angle - THETA(rho,theta)
       if (rank .eq. 0) then
	      open (UNIT = 777, FILE = paplda // 'pitchangle.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
          write(777,*), 'Pitch angle'
          write(777,*), ' rad ' , ' pol ', ' pla ' 
          write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
          do j = 1, ist11
             aux = intaplot(j)		
             write(777,2222)(dasin(eqt(aux,ipo,15)), ipo = 1, nploth+1)
          end do
          close(777)

c     3.2) Toroidal magnetic field - Btor(rho,theta) = |B|.cos(THETA)
          open (UNIT = 777, FILE = paplda // 'Btor.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
          write(777,*), 'Toroidal magnetic field'
          write(777,*), ' rad ' , ' pol ', ' pla ' 
          write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
          do j = 1, ist11
              aux = intaplot(j)		
              write(777,2222)(bmotab(aux,ipo)*eqt(aux,ipo,14), ipo = 1, nploth+1)
	      end do
	      close(777)
      end if ! (rank .eq. 0)
	endif	


c     3.3) Parameter mu = (d2Zdth2*dRdth - d2Rdth2*dZdth) / ntn**2 
c	     NB: This parameter is only saved for checking, since it
c		     contains several geometrical coefficients.
c	open (UNIT = 777, FILE = paplda // 'mu.dat', 
c     ;      STATUS = "REPLACE", ACTION = "WRITE")
c		write(777,*), 'mu = (d2Zdth2*dRdth - d2Rdth2*dZdth) / ntn**2'
c		write(777,*), ' rad ' , ' pol ', ' pla ' 
c		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
c		do j = 1, ist11
c		   aux = intaplot(j)	
c		   write(777,2222)(eqt(aux,ipo,10), ipo = 1, nploth+1)
c		end do
c	close(777)

c     3.4) Poloidal metric coefficient N_theta (normalized)
c	open (UNIT = 777, FILE = paplda // 'N_theta.dat', 
c     ;      STATUS = "REPLACE", ACTION = "WRITE")
c		write(777,*), 'Normalized Poloidal metric coef. N_theta 
c     ; = sqrt(drthn*drthn + dzthn*dzthn)'
c		write(777,*), ' rad ' , ' pol ', ' pla ' 
c		write(777, "(i5, i5, i5)"), ist11, nploth+1, ipla 
c		do j = 1, ist11
c		   aux = intaplot(j)	
c		   write(777,2222) (eqt(aux,ipo,7), ipo = 1, nploth+1)
c		end do
c	close(777)

c     3.5) dR/drho
c	open (UNIT = 777, FILE = paplda // 'dRdrho.dat', 
c     ;      STATUS = "REPLACE", ACTION = "WRITE")
c		write(777,*), 'dRdrho'
c		write(777,*), ' rad ' , ' pol ', ' pla ' 
c		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
c		do j = 1, ist11
c		   aux = intaplot(j)	
c		   write(777,2222)(eqt(aux,ipo,3), ipo = 1, nploth+1)
c		end do
c	close(777)

c     3.6) 1/rho dR/dtheta
c	open (UNIT = 777, FILE = paplda // 'dRdthn.dat', 
c    ;      STATUS = "REPLACE", ACTION = "WRITE")
c		write(777,*), 'dRdthn'
c		write(777,*), ' rad ' , ' pol ', ' pla ' 
c		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
c		do j = 1, ist11
c		   aux = intaplot(j)	
c		   write(777,2222)(eqt(aux,ipo,4), ipo = 1, nploth+1)
c		end do
c	close(777)

c     3.7) dZ/drho
c	open (UNIT = 777, FILE = paplda // 'dZdrho.dat', 
c    ;      STATUS = "REPLACE", ACTION = "WRITE")
c		write(777,*), 'dZdrho'
c		write(777,*), ' rad ' , ' pol ', ' pla ' 
c		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
c		do j = 1, ist11
c		   aux = intaplot(j)	
c		   write(777,2222)(eqt(aux,ipo,5), ipo = 1, nploth+1)
c		end do
c	close(777)

c     3.8) 1/rho dZ/dtheta
c	open (UNIT = 777, FILE = paplda // 'dZdthn.dat', 
c     ;      STATUS = "REPLACE", ACTION = "WRITE")
c		write(777,*), 'dZdthn'
c		write(777,*), ' rad ' , ' pol ', ' pla ' 
c		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
c		do j = 1, ist11
c		   aux = intaplot(j)	
c		   write(777,2222)(eqt(aux,ipo,6), ipo = 1, nploth+1)
c		end do
c	close(777)

c     4) 2D COKPCO tables  ---------------------------------------

      if(cokpco .and. rank .eq. 0)then

c     4.1) Magnetic angle Chi 
	open (UNIT = 777, FILE = paplda // 'Chi.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
		write(777,*), 'Magnetic angle Chi (cokpco)'
		write(777,*), ' rad ' , ' pol ', ' pla ' 
		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
		do j = 1,ist11
		   aux = intaplot(j)
		   write(777,2222)(ckt(aux,ipo,5), ipo = 1, nploth+1)
		end do
	close(777)	

c     4.2) Thetabar coordinate 
	open (UNIT = 777, FILE = paplda // 'Thetabar.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
		write(777,*), 'Thetabar (cokpco)'
		write(777,*), ' rad ' , ' pol ', ' pla ' 
		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
		do j = 1,ist11
		   aux = intaplot(j)
		   write(777,2222)(ckt(aux,ipo,3), ipo = 1, nploth+1)
		end do
	close(777)	

c     4.3) Phibar coordinate 
	open (UNIT = 777, FILE = paplda // 'Phibar.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
		write(777,*), 'Phibar (cokpco)'
		write(777,*), ' rad ' , ' pol ', ' pla ' 
		write(777,"(i5, i5, i5)"), ist11, nploth+1, ipla 
		do j = 1,ist11
	       aux = intaplot(j)
		   write(777,2222)(ckt(aux,ipo,4), ipo = 1, nploth+1)
		end do
	close(777)	

	end if ! (cokpco)  and (rank .eq. 0)

c     5) SPECIES tables (1D) ---------------------------------------

         if (rank .eq. 0) then
          open (UNIT = 701, FILE = paplda // 'species.dat', 
     ;      STATUS = "REPLACE", ACTION = "WRITE")
          write(701,"(i3)"), nspec
	      write(701,*), paname(1:nspec)
	      write(701,*), qom(1:nspec)
	      write(701,*), fregag
	      write(701,"(20f8.3)"), spefra(1:nspec,1)
	      write(701,"(20f8.3)"), zch(1:nspec)
	      close(701) 


c     6) Special outpur for GNUPLOT scripts


          open(UNIT = 777, FILE = paplda // 'gnu_header.dat',
     ;       STATUS = "UNKNOWN", ACTION = "WRITE")
          write(777,*) 'Header file for GNUPLOT scripts'
          write(777,*) 'NSPEC, SPEC_names, rp, Ro, N, Rmin, Rmax'
          write(777,*) nspec
          write(777,*) paname(1:nspec)
          write(777,*) rx0m(1)
          write(777,*) r0
          write(777,*) motoan(1)
          close(777)

      end if ! (rank .eq. 0)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	

      return

 2222 format(200(g14.6))   

      end
