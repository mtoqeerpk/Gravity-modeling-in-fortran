      SUBROUTINE INVER(ITER)
      COMMON/INV/DIST(75),NSTAT,GRAV(75),GTOT(75),MAG(75),MTOT(75),NPOLY
     2,NSIDES(12),Z(12,25),X(12,25),ELEV(75),SL(12),DENSTY(12),CT,SUSCP(
     112),NBASE,IAN
      DIMENSION NDEN(12),NSUS(12),A1(150,50),IVZ(12,20),IVX(12,20),GTE(1
     32,75),GDIF(150),MDIF(150),S(50),V(50,50),E(150),W(150),ATW(150,150
     4),DEL(50)
      REAL MAG,MTOT,MTE(12,75),MTR,MDIF
      COMMON/BLKA1/ATW
      IM=ITER
      MPAR=0
      WRITE(6,444)
  444 FORMAT(' TO WHAT DEVICE DO YOU WISH TO WRITE?')
      READ(5,126) IIW
C
C     SET VARIABLES
C
      WRITE(6,134)
      READ(5,126)VG,VM
      MSTAT=NSTAT*2
      IF(IAN.GT.0)GO TO 888
      WRITE(6,127)
      READ(5,126)IDEN,ISUS,IVER
      GO TO 887
  888 IDEN=0
      ISUS=0
      IVER=0
  887 CONTINUE
      DO 828 I=1,NPOLY
      NDEN(I)=0
      NSUS(I)=0
      NS=NSIDES(I)+1
      DO 28 J=1,NS
      IVX(I,J)=0
      IVZ(I,J)=0
   28 CONTINUE
  828 CONTINUE
C
C     INPUT PARAMETERS FOR INVERSION
C
      ITEST=0
      IF(IDEN.LE.0)GO TO 991
      WRITE(6,126)
      DO 21 I=1,IDEN
      READ(5,126)ID,N
      NDEN(ID)=N
      IF(ITEST.LT.N)ITEST=N
   21 CONTINUE
  991 CONTINUE
      IF(ISUS.LE.0)GO TO 990
      WRITE(6,129)
      DO 22 J=1,ISUS
      READ(5,126)IS,N
      NSUS(IS)=N
      IF(ITEST.LT.N)ITEST=N
   22 CONTINUE
  990 CONTINUE
      IF(IVER.LE.0)GO TO 950
      WRITE(6,132)
      READ(5,126)IANS
      J=1
      IF(IANS.LE.0)GO TO 988
  987 CONTINUE
      WRITE(6,130)
      DO 23 I=1,IANS
      READ(5,126)K,M,N
      IF(J.EQ.2)IVX(K,M)=N
      IF(ITEST.LT.N)ITEST=N
      IF(J.EQ.2)IVX(K,M)=N
      IF(ITEST.LT.N)ITEST=N
   23 CONTINUE
      IF(J.EQ.2)GO TO 950
  988 CONTINUE
      WRITE(6,133)
      READ(5,126)IANS
      J=2
      IF(IANS.GT.0)GO TO 987
  950 CONTINUE
      MPAR=IDEN+ISUS+IVER
      IF(ITEST.LT.MPAR)MPAR=ITEST
      WRITE(IIW,131)MPAR
  989 CONTINUE
C
C     ZERO OUT ARRAYS
C
      DO 5 I=1,NSTAT
      GTOT(I)=0.0
      MTOT(I)=0.0
      DO 9 J=1,NPOLY
      GTE(J,I)=0.0
    9 MTE(J,I)=0.0
    5 CONTINUE
      DO 24 I=1,NSTAT
      DO 24 J=1,MPAR
      K=NSTAT+I
      A1(I,J)=0.0
   24 A1(K,J)=0.0
      DO 6 I=1,NPOLY
      N=NSIDES(I)
      SL1=SL(I)
      DO 7 J=1,NSTAT
      L=NSTAT+J
      DO 8 K=1,N
      X1=X(I,K)-DIST(J)
      X2=X(I,K+1)-DIST(J)
      EL=ELEV(J)
      Z1=Z(1,K)
      Z2=Z(1,K+1)
      CALL TALW(Z1,Z2,X1,X2,SL1,A,B,EL)
      GTE(I,J)=GTE(I,J)+A
      MTE(I,J)=MTE(I,J)+B
      IF(ITER.EQ.0)GO TO 982
C
C      MOVE VERTICES VERTICALLY BY 10%
C
      IF(IVZ(I,K).EQ.0.AND.IVZ(I,K+1).EQ.0)GO TO 986
      IDV=IVZ(I,K+1)
      IF(IDV.EQ.0)GO TO 985
      XPL=Z2/10.
      ZZ2=Z2+XPL
      CALL TALW(Z1,ZZ2,X1,X2,SL1,A2,B2,EL)
      A1(J,IDV)=A1(J,IDV)+((A2-A)/XPL)*DENSTY(I)*CT
      A1(L,IDV)=A1(L,IDV)+((B2-B)/XPL)*SUSCP(I)
  985 CONTINUE
      IDV=IVZ(I,K)
      IF(IDV.EQ.0)GO TO 986
      XPL=Z1/10.
      ZZ1=Z1+XPL
      CALL TALW(ZZ1,Z2,X1,X2,SL1,A2,B2,EL)
      A1(J,IDV)= A1(J,IDV)+((A2-A)/XPL)*DENSTY(I)*CT
      A1(L,IDV)=A1(L,IDV)+((B2-B)/XPL)*SUSCP(I)
  986 CONTINUE
C
C     MOVES VERTICES HORIZONTALLY BY 10% OF THE DEPTH
C
      IF(IVX(I,K).EQ.0.AND.IVX(I,K+1).EQ.0)GO TO 984
      IDV=IVX(I,K+1)
      IF(IDV.EQ.0)GO TO 983
      XPL=Z2/10.
      CALL TALW(Z1,Z2,X1,XX2,SL1,A2,B2,EL)
      A1(J,IDV)=A1(J,IDV)+((A2-A)/XPL)*DENSTY(I)*CT
      A1(L,IDV)=A1(L,IDV)+((B2-B)/XPL)*SUSCP(I)
  983 CONTINUE
      IDV=IVX(I,K)
      IF(IDV.EQ.0)GO TO 984
      XPL=Z2/10.
      XX1=X1+XPL
      CALL TALW(Z1,Z2,XX1,X2,SL1,A2,B2,EL)
      A1(J,IDV)=A1(J,IDV)+((A2-A)/XPL)*DENSTY(I)*CT
      A1(L,IDV)=A1(L,IDV)+((B2-B)/XPL)*SUSCP(I)
  984 CONTINUE
  982 CONTINUE
    8 CONTINUE
    7 CONTINUE
    6 CONTINUE
C
C
C
      DO 10 I=1,NSTAT
      K=STAT*1
      DO 10 J=1,NPOLY
      SGN=1.
      SGM=1.
      IF(DENSTY(J).LT.0.0)SGN=-1.
      IF(SUSCP(J).LT.0.0)SGM=-1.
      ND=NDEN(J)
      NS=NSUS(J)
      IF(ND.NE.0)A1(I,ND)=A1(I,ND)+GTE(J,I)*SGN
      IF(NS.NE.0)A1(K,NS)=A1(K,NS)+MTE(J,I)*SGM
      MTOT(I)=MTOT(I)+MTE(J,I)*SUSCP(J)
   10 GTOT(I)=GTOT(I)+GTE(J,I)*DENSTY(J)*CT
      GTR=GTOT(NBASE)-GRAV(NBASE)
      MTR=MTOT(NBASE)-MAG(NBASE)
      SSRM=0.0
      SSR=0.0
      DO 11 I=1,NSTAT
      GTOT(I)=GTOT(I)-GTR
      GDIF(I)=GRAV(I)-GTOT(I)
      DIFSQ=GDIF(I)**2
      SSR=SSR+DIFSQ
   11 SSRM=SSRM+DIFSQ
      CHISQ=(SSR/VG)+(SSRM/VM)
  962 CONTINUE
      WRITE(IIW,138)
      DO 720 I=1,NPOLY
      WRITE(IIW,139)I,DENSTY(I),SUSCP(I),SL(I)
      WRITE(IIW,140)
      NS=NSIDES(I)+1
      DO 20 J=1,NS
      WRITE(IIW,141)X(I,J),Z(I,J),I,J
   20 CONTINUE
  720 CONTINUE
      WRITE(IIW,117)
      WRITE(IIW,118)
      DO 14 I=1,NSTAT
      WRITE(IIW,119)I,DIST(I),GRAV(I),GTOT(I),MAG(I),MTOT(I),GDIF(I),MDI
     *F(I)
   14 CONTINUE
      WRITE(IIW,120)SSR,SSRM
      GVAR=SSR/(NSTAT-MPAR)
      VARM=SSRM/(NSTAT-MPAR)
      WRITE(IIW,121)GVAR,VARM
      GSD=SQRT(GVAR)
      SDM=SQRT(GVAR)
      WRITE(IIW,122)GSD,SDM
      VTOT=CHISQ/(MSTAT-MPAR)
      SDV=SQRT(VTOT)
      WRITE(6,135)CHISQ,VTOT,SDV
      IF(IVER.EQ.0)GO TO 981
C
C     GAUSS METHOD
C
      DO 33 I=1,NSTAT
      J=NSTAT+I
      DO 37 K=1,MPAR
      A1(I,K)=A1(I,K)/VG
   37 A1(J,K)=A1(J,K)/VM
      L=MPAR+1
      A1(I,L)=GDIF(I)/VG
      A1(J,L)=MDIF(I)/VM
   33 CONTINUE
      CALL SVD(AQ,S,V,150,50,MSTAT,MPAR,1,.TRUE.,.TRUE.)
      P=.0001
  975 CONTINUE
      IP=0
      DO 34 I=1,MPAR
      WRITE(IIW,1004)I,S(I) 
      IF(S(I).LT.P)GO TO 978
      IP=IP+1
      MDIF(I)=1./S(I)
      GO TO 34
  978 MDIF(I)=0.
   34 CONTINUE
      WRITE(IIW,142)IP
      DO 35 I=1,IP
      K=MPAR+1
   35 E(I)=MDIF(I)*A1(I,K)
      DO 36 J=1,IP
   36 DEL(I)=W(I)+V(I,J)*E(J)
       DO 32 I=1,MPAR
      WRITE(6,1003)DEL(I)
      DO 32 J=1,NPOLY
      IF(NDEN(J).EQ.I)DENSTY(J)=DENSTY(J)+DEL(I)
      IF(NSUS(J).EQ.I)SUSCP(J)=SUSCP(J)+DEL(I)
      NS=NSIDES(J)+1
      DO 32 K=1,NS
      IF(IVZ(J,K).EQ.I)Z(J,K)=Z(J,K)+DEL(I)
      IF(Z(J,K).LT.0.)Z(J,K)=Z(J,K)-DEL(I)
      IF(IVX(J,K).EQ.I)X(J,K)=X(J,K)+DEL(I)
   32 CONTINUE
      ITER=ITER-1
      GO TO 989
  981 CONTINUE
  117 FORMAT('  STAT DISTANCE OBSERVED COMPUTED OBSERVED COMPUTED
     * DIFF  DIFF')
  118 FORMAT('  NO',9X,'   GRAVITY  GRAVITY  MAGNETIC MAGNETIC  G
     *RAV  MAG')
  119 FORMAT(' ',I3,3X,F6.2,3X,F8.2,4X,F8.2,2X,F5.0,4X,F5.0,3X,F6.
     *2,1X,F6.1)
  120 FORMAT('   THE TOTAL SUM OF THE SQUARES FOR GRAVITY IS ',
     *F15.3,'   MAGNETICS IS',F15.0)
  121 FORMAT(' THE VARIENCE FOR GRAVITY IS ',F14.3,'  MAGNETICS ',
     *F14.0)
  122 FORMAT(' THE STANDARD DEVIATION FOR GRAVITY IS ',F10.3,' MAG
     *NETICS IS ',F8.0)
  126 FORMAT()
  127 FORMAT(' INPUT NO. OF DENSITY,SUSCEPTABLILITY, VERTEX PARAME
     *TERS TO BE ADJUSTED')
  128 FORMAT(' INPUT THE POLYGON NO.S FOR THE DENSITIES & ORDER NO')
  129 FORMAT(' INPUT THE POLYGON NO.S FOR THE SUSCEPTIBILITIES&ORDER
     * NO.')
  130 FORMAT(' INPUT THE REF NO.S (I,J) OF THE VERTICES & ORDER NO')
  131 FORMAT(' A TOTAL OF ',I4,' PARMETERS TO BE ADJUSTED')
  132 FORMAT(' TOTAL NO OF VERTICAL VERTEX ADJUSTMENTS')
  133 FORMAT(' TOTAL NO OF HORIZONTALVERTEX ADJUSTMENTS')
  134 FORMAT(' INPUT THE ESTIMATED VARIANCE FOR GRAVITY, MAGNETICS')
  135 FORMAT(' THE CHI SQ OBJECTIVE FUNCTION IS ',F10.3,' COMBINED 
     *VARIANCE IS ',F8.2,' STANDARD DEVIATION IS ',F8.2)
  136 FORMAT(' EIGENVALUE NO. ',I3,' = ',F15.5)
  137 FORMAT('  THE MATRIX ATA IS SINGULAR')
  138 FORMAT(' THE NEW PARAMETERS ARE:')
  139 FORMAT(' ',4X,'POLYGON NO.',I2,5X,'DENSITY',F8.5,'SUSCEPTIBILI
     *TY ',F7.5,15X,' STRIKE LENGTH ',F10.3)
  140 FORMAT(' ',5X,'X VERTICES',5X,'Z VERTICES',6X,'REF')
  141 FORMAT(' ',4X,F10.3,4X,F10.3,4X,I2,1X,I2)
  142 FORMAT('  P= ',I2)
  143 FORMAT(' THE RESOLUTION MATRIX IS:')
  144 FORMAT(' ROW ',I2,(10F6.3/))
  145 FORMAT(' THE INFORMATION DENSITY MATRIX IS ')
  146 FORMAT(' THE CUTOFF FOR SMALL EIGENVALUES IS ',F10.9,' DO YOU
     *WISH TO CHANGE THIS? YES=0,NO=1')
  147 FORMAT(' INPUT NEW CUTOFF')
  148 FORMAT(' THE COVARIANCE MATRIX IS:')
  149 FORMAT(' THE CORRELATION MATRIX IS:')
  150 FORMAT(' ROW ',I3,(12(1X,F4.2)))
  151 FORMAT(' THE COMPUTED VARIANCE FOR GRAVITY ',F10.3,' MAGNETICS
     * ',F10.3,' WOULD YOU LIKE TO CHANGE THIS? YES=0,NO=1')
  152 FORMAT(' DO YOU WISH TO SEE THE INFORMATION DENSITY MATRIX? 
     *YES=0,NO=1')
  153 FORMAT(' THIS PROGRAM CAN USE EITHER THE GAUSS METHOD OR THE
     *MARQUARDT METHOD.  iT IS SET NOW TO DO ONLY THE MARQUARDT. DO
     1YOU WISH TO CHANGE THIS? YES=0,NO=1')
  154 FORMAT(' INPUTE THE NUMBER OF ITERATIONS FOR THE GAUSS ')
 1003 FORMAT('  DEL= ',F10.4)
 1004 FORMAT(' LAMBDA ',I2,' = ',F15.6)
      RETURN
      END