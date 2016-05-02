      subroutine aqwrite(AQP, VEC, IBLK, NBLK, IWRI, IQUEUE, ISTATU)
      USE GLOBAL
      implicit none
      integer aqp, iblk, nblk, iwri, iqueue, istatu
      double precision vec(*)

      INCLUDE 'pardim.copy'
      include 'mpif.h'
c      INCLUDE 'paralelo.copy'

      integer irec, i, j
	  
C     Normal WRITE:
	  IREC = IBLK
      DO I = 1, NBLK
      IF (rank .eq. 0) WRITE(UNIT=aqp, REC=IREC, IOSTAT=ISTATU)
     ;     (VEC(J), J = 1 + IOBLL * (I-1), I*IOBLL)
	  IREC = IREC + 1
      END DO    
        
      return
      end
