      SUBROUTINE WRP1D(NOFILE, IPLOT, N, X, Y, LDY, INCY, NCURV, TITLE
     ;, XUNIT, XLABEL, YUNIT, YLABEL, NTEXT, TEXT, HEADER)
      USE GLOBAL
      IMPLICIT NONE
      include 'mpif.h'
c      INCLUDE 'paralelo.copy'
      LOGICAL HEADER
      
      INTEGER NOFILE, IPLOT, N, LDY, INCY, NCURV, NTEXT
      
      DOUBLE PRECISION X(N), Y(LDY,1+(NCURV-1)*incy)
      
      CHARACTER*48 TITLE, XLABEL, YLABEL(NCURV), TEXT(NTEXT)
      
      CHARACTER*10 XUNIT, YUNIT
C
C     Writes 1d plot data to output file. 
C     There are NCURV curves and N abscissae.
C
      INTEGER I, j

      if (rank .eq. 0) WRITE(NOFILE,1001)TITLE
      if (rank .eq. 0)WRITE(NOFILE,*)N, NCURV+1, NTEXT
      
      if(header)then
c      WRITE(NOFILE,1001)IPLOT, TITLE
c      WRITE(NOFILE,*)N, NCURV, NTEXT
      if (rank .eq. 0) WRITE(NOFILE,1002)XLABEL, (YLABEL(j),j=1,NCURV)
      if (rank .eq. 0) WRITE(NOFILE,1003)XUNIT, YUNIT
      IF(NTEXT.GT.0 .and. rank .eq. 0)WRITE(NOFILE,*)(TEXT(j),j=1,NTEXT)
      end if
      if (rank .eq. 0) then 
      DO I = 1, N
      WRITE(NOFILE,1000) X(I), (Y(I,1+(j-1)*INCY),j=1,NCURV)
      END DO
	 end if !(rank .eq. 0) 
      
      RETURN
 1000 format(1h ,10(1x, g15.7))
 1001 format(1h ,a48)
 1002 format(1h ,10(1x,a48))
 1003 format(1h ,2(1x,a10))
      END
