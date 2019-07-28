
 LIBNAME hw5 'H:\Data\HW5'; 
DATA churn; SET hw5.churn; RUN; 
/*viewing contents of Churn*/ 
PROC PRINT DATA = churn (OBS = 10);RUN; 
PROC CONTENTS DATA = churn; RUN; 
/*Means of variables for churners and non churners*/ 
PROC SORT DATA=churn; BY churn; RUN; 
PROC MEANS DATA=churn; 
BY churn; 
OUTPUT OUT=means MEAN=; 
RUN; QUIT; 
PROC CONTENTS DATA= means; RUN; 
/*Transposing the means data*/ 
DATA NM; SET means; RUN; 
PROC TRANSPOSE DATA = NM; RUN; 
/*Setting Transposed dataset to TNM*/ 
DATA TNM; SET WORK.DATA1; RUN; 
PROC CONTENTS DATA = TNM; RUN; 
/*Calculating percentage Means difference in the variables*/ 
DATA AOC; SET TNM; 
avg = (COL1 + COL2)/2; RUN; 
DATA PCT; SET AOC; 
PCT = ABS(((COL1 - COL2)/avg)*100); RUN; 
/*Sorting the percentage means difference in descending order*/ 
PROC SORT DATA = PCT; BY DESCENDING PCT; RUN; 
PROC CONTENTS DATA = PCT; RUN; 
/*Correlation Test*/ 
PROC CORR DATA = churn; VAR change_mou change_rev blck_dat_Mean roam_Mean drop_dat_Mean mou_opkd_Mean threeway_Mean custcare_Mean callfwdv_Mean opk_dat_Mean;RUN; 
DATA D1 ; SET churn; 
KEEP change_mou change_rev blck_dat_Mean roam_Mean drop_dat_Mean mou_opkd_Mean threeway_Mean custcare_Mean callfwdv_Mean opk_dat_Mean; RUN; 
PROC PRINT DATA = D1 (OBS = 100); RUN; 
/*Logistic Model*/ 
DATA D2; 
SET churn(KEEP = refurb_new retdays rmrev change_mou change_rev blck_dat_Mean roam_Mean drop_dat_Mean mou_opkd_Mean threeway_Mean custcare_Mean callfwdv_Mean opk_dat_Mean asl_flag churn); 
IF asl_flag ='N' THEN asl_flag_N = 0; 
IF asl_flag ='Y' THEN asl_flag_N = 1; 
IF refurb_new = 'N' THEN refurb = 0; 
IF refurb_new = 'R' THEN refurb = 1; 
RUN; 
DATA D3; 
SET D2 (DROP = asl_flag refurb_new); 
RUN; 
PROC MEANS NMISS N DATA=D3;RUN; 
PROC PRINT DATA=D3(OBS=10);RUN; 
PROC LOGISTIC DATA=D3 OUTEST=betas COVOUT; 
MODEL churn(EVENT='1')=refurb change_mou change_rev blck_dat_Mean roam_Mean drop_dat_Mean mou_opkd_Mean threeway_Mean custcare_Mean callfwdv_Mean opk_dat_Mean asl_flag_N/ctable pprob=0.5; 
OUTPUT OUT=pred p=phat lower=lcl upper=ucl 
predprob=individual; 
ODS OUTPUT Association=Association; 
RUN;

PROC PRINT DATA = pred (OBS=10);RUN; 
DATA pred;SET pred; 
pred_dis=0; 
IF phat>0.5 THEN pred_dis=1; 
RUN; 
PROC FREQ DATA=pred; 
TABLES churn*pred_dis / 
norow nocol nopercent; 
RUN;
