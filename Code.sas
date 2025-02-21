/* 1. Importer les données pour en faire une table SAS*/
LIBNAME lib "/home/u64135292/sasuser.v94";

PROC IMPORT DATAFILE="~sasuser.v94/Panel95light.csv"
    OUT=panel
    DBMS=CSV
    REPLACE;
  GUESSINGROWS=MAX;
RUN;



/* 2. Représentation graphique de la distribution des variables lw, etudes, sexe, exper, mois.*/
PROC UNIVARIATE DATA = panel;
  VAR lw;
  HISTOGRAM lw / NORMAL;
  TITLE "Distribution du log-salaire";
  
PROC sgplot data = panel;
  vbar etudes;
  TITLE "Distribution de etudes";
run;

PROC UNIVARIATE DATA = panel;
  VAR exper;
  HISTOGRAM exper / NORMAL;
  TITLE "Distribution de l’expérience";
  
PROC sgplot data = panel;
  vbar mois;
  title "Distribution du mois";
run;

PROC FREQ data=panel;
  tables sexe / out=sex_freq outpct;
run;

proc gchart data=panel;
    pie sexe / type=percent value=inside;
    title "Distribution du sexe";
run;
quit; 

/* 3. Générer des indicatrices pour chaque niveau d'études, ainsi que la variable numérique sexN, 
qui vaut 1 pour les hommes, 2 pour les femmes, puis des indicatrices de sexe masculin et féminin.*/
data panel_2;
    set panel;
    primaire = 0;
    secondaire = 0;
    professionnel_court = 0;
    professionnel_long = 0;
    deuxieme_cycle = 0;
    troisieme_cycle = 0;
  sexeN = 1;
  masculin = 0;
  feminin = 0;
    
    
    if etudes = "primaire" then primaire = 1;
    else if etudes = "secondaire" then secondaire = 1;
    else if etudes = "professionnel court" then professionnel_court = 1;
    else if etudes = "professionnel long" then professionnel_long = 1;
    else if etudes = "deuxieme cycle" then deuxieme_cycle = 1;
    else if etudes = "troisieme cycle" then troisieme_cycle = 1;
    
    if sexe = "Femme" then sexeN = 2;
    
    if sexe = "Homme" then masculin = 1;
    else if sexe = "Femme" then feminin = 1;

run;


/* 4. Calculer le log-salaire moyen par niveau d'étude, ainsi que le log-salaire moyen dans l'échantillon., 
et sauvegardezles résultats dans une table. */
PROC MEANS DATA=panel N NMISS MEAN;
  CLASS etudes;
  VAR lw;
  OUTPUT OUT=results(DROP=_TYPE_ _FREQ_) 
    N=Obs 
    MEAN=Moyenne;
RUN;

PROC MEANS DATA=panel N NMISS MEAN;
  VAR lw;
  OUTPUT OUT=overall(DROP=_TYPE_ _FREQ_) 
    N=Obs  
    MEAN=Moyenne;
RUN;

DATA final;
  SET results overall;
  LENGTH etudes $50;
  IF MISSING(etudes) THEN etudes = "Total échantillon";
RUN;

PROC SORT DATA=final NODUPKEY;
  BY etudes;
RUN;

PROC PRINT DATA=final;
RUN;



/*5. Estimation des différents modèles de régression du log du salaire suivants, 
en ajoutant à la table initiale le salaire prédit par chaque modèle : */

/*(a) tous les niveaux d'étude, "sans précaution" */
PROC REG DATA=panel_2 ;
    MODEL lw = primaire secondaire professionnel_court professionnel_long deuxieme_cycle troisieme_cycle / CLB;
    OUTPUT OUT=panel_2 PREDICTED=sal_pred_a;
    title "Reg toutes indicatrices sans precaution";
RUN;

/*(b) tous les niveaux d'étude, sans constante */
PROC REG DATA=panel_2 ;
    MODEL lw = primaire secondaire professionnel_court professionnel_long deuxieme_cycle troisieme_cycle / NOINT CLB;
    OUTPUT OUT=panel_2 PREDICTED=sal_pred_b;
    title "Reg toutes indicatrices sans constante";
RUN;

/*(c) tous les niveaux d'étude sauf primaire (référence 1) */
PROC REG DATA=panel_2 ;
    MODEL lw = secondaire professionnel_court professionnel_long deuxieme_cycle troisieme_cycle / CLB;
    OUTPUT OUT=panel_2 PREDICTED=sal_pred_c;
    title "Reg toutes indicatrices sauf primaire";
RUN;

/* (d) tous les niveaux d'étude sauf cycle 3 (référence 6) */
PROC REG DATA=panel_2;
  MODEL lw = primaire secondaire professionnel_court professionnel_long deuxieme_cycle / SELECTION=STEPWISE;
  OUTPUT OUT=panel_2 PREDICTED=sal_pred_d;
  TITLE "Reg toutes indicatrices sauf cycle 3";
RUN;
QUIT;

/* (e) Nullité de la moyenne pondérée des coefficients */
PROC REG DATA=panel_2;
    MODEL lw = primaire secondaire professionnel_court professionnel_long deuxieme_cycle troisieme_cycle;
    RESTRICT 
        924*primaire + 1308*secondaire + 2664*professionnel_court + 732*professionnel_long 
        + 2292*deuxieme_cycle + 936*troisieme_cycle = 0;
    OUTPUT OUT=panel_2 PREDICTED=sal_pred_e;
    TITLE "Nullité de la moyenne pondérée des coefficients";
RUN;
QUIT;

/* (f) Nullité de la moyenne non pondérée des coefficients */
PROC REG DATA=panel_2;
    MODEL lw = primaire secondaire professionnel_court professionnel_long deuxieme_cycle troisieme_cycle;
    RESTRICT primaire + secondaire + professionnel_court + professionnel_long + deuxieme_cycle + troisieme_cycle = 0;
    OUTPUT OUT=panel_2 PREDICTED=sal_pred_f;
    TITLE "Nullité de la moyenne non pondérée des coefficients";
RUN;
QUIT;

/* 6. Corrélation entre le log-salaire prédit et le log-salaire observé pour chaque modèle */

PROC CORR DATA=panel_2;
  VAR lw sal_pred_a sal_pred_b sal_pred_c sal_pred_d sal_pred_e sal_pred_f;
  TITLE "Corrélation entre le log-salaire observé et les prédictions des modèles (a, b, c, d, e, f)";
RUN;

/* 7. Tableaux des coefficients estimés pour chaque modèle et des statistiques globales des modèles*/

DATA coef_a; SET coef_a; modele="A"; RUN;
DATA coef_b; SET coef_b; modele="B"; RUN;
DATA coef_c; SET coef_c; modele="C"; RUN;
DATA coef_d; SET coef_d; modele="D"; RUN;
DATA coef_e; SET coef_e; modele="E"; RUN;
DATA coef_f; SET coef_f; modele="F"; RUN;

DATA stats_a; SET stats_a; modele="A"; RUN;
DATA stats_b; SET stats_b; modele="B"; RUN;
DATA stats_c; SET stats_c; modele="C"; RUN;
DATA stats_d; SET stats_d; modele="D"; RUN;
DATA stats_e; SET stats_e; modele="E"; RUN;
DATA stats_f; SET stats_f; modele="F"; RUN;

DATA all_coef;
    SET coef_a coef_b coef_c coef_d coef_e coef_f;
RUN;

DATA all_stats;
    SET stats_a stats_b stats_c stats_d stats_e stats_f;
RUN;

PROC PRINT DATA=all_coef;
    TITLE "Tableau des coefficients estimés pour chaque modèle";
RUN;

PROC PRINT DATA=all_stats;
    TITLE "Tableau des statistiques globales des modèles";
RUN;
