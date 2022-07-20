
forvalues g = 3(1)5 { // loop for event win length
    forvalues h = 1(2)3 { //loop for reg_type
        forvalues j = 255(3745)4000 { // loop for est win length
            *** SET WD

	cd "C:\Users\jonas\OneDrive - London School of Economics\Documents\LSE\GY489_Dissertation\LETS GO\Dissertation-Code-Data"

	
*** IMPORT DATA
	clear all
	import delimited "Data.csv"
	
	/* Install package mmerge!*/

/*
- data: choose variables by trading volume?!
*/

*** PREP DATA
	scalar treat_missing = 1 // 0: let Stata deal with missing values; 1: drop all observation for which there is a missing value in one of the explanatory variables or outcome variable; 2: XXXX; 3: XXX
	quietly do data_prep

	d

*** DATA DESCRIPTIVE
	quietly do data_descriptive
		
*** GENERATE (AB)NORMAL RETURNS

	** Define scalars/matrices

		* Test one specific date only (independent of country exit dates)
			scalar test_specific_date = "no" // "yes" when determining one specific date only; must be unequal "yes" when analysing countries' coal phase-outs

			scalar date_specific = 20130416 // determine date to be tested if test_specific_date == "yes"

		* Phase out announcements
			quietly do phase_out

				
		* Event Study Settings
			scalar event_length_pre = `g' // length of event window pre event (days)
			scalar event_length_post = `g' // length of event window post event (days)

			scalar est_length = `j' // length of estimation window (days)
			scalar earliest_date = 20080314 // earliest date for estimation window
						
			scalar reg_type = `h' // 1: constant mean return 2: zero mean return 3: model with many explanatory variables 3.1: first difference of log returns for coal+gas 3.2: for all D_
			
			scalar show_days = 1 // 1: show not only pre / post estimations but also every single day
			
			scalar price = "yes"
			scalar volume = "n"


	quietly do event_study

*** Postestimation: Test significance
	quietly do post_estimation
	 do significance
	
*** Formatted Output
	do output
        }
    }
}



