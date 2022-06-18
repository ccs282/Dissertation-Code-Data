
*** SET WD

	cd "C:\Users\jonas\OneDrive - London School of Economics\Documents\LSE\GY489_Dissertation\LETS GO\Dissertation-Code-Data"

	
*** IMPORT DATA
	clear all
	import delimited "Data.csv"
	
	/* Install package mmerge!*/

/*
Wrong Data:
- EUA december ahead needed; currently MO1 used
- offset prices same
- check oil coal gas elec
*/

*** PREP DATA
	quietly do data_prep

	d

*** DATA DESCRIPTIVE
	quietly do data_descriptive
		
*** GENERATE (AB)NORMAL RETURNS

	** Define scalars/matrices

		* Phase out announcements
			quietly do phase_out

			matrix list announce_date
			
		* Which dates to analyse?
			
			* Test one specific date only (independent of country exit dates)
				scalar test_specific_date = "yes" // "yes" when determining one specific date only; must be unequal "yes" when analysing countries' coal phase-outs

				scalar date_specific = 20130416 // determine date to be tested if test_specific_date == "yes"

			* Test coal phase-out dates from matrix 
				scalar Germany_num = 		1 // 0-4
				scalar UK_num = 			1 // 0-3
				scalar Spain_num = 			1 // 0-4
				scalar Italy_num = 			1 // 0-2
				scalar Czech_Republic_num = 1 // 0-2
				scalar Netherlands_num = 	1 // 0-3
				scalar France_num = 		1 // 0-3
				scalar Romania_num = 		1 // 0-3
				scalar Bulgaria_num = 		1 // 0-1
				scalar Greece_num = 		1 // 0-3
				scalar Others_num = 		0 // 0-?

		* Event Study parameters
			scalar event_length_pre = 3 // length of event window pre event (days)
			scalar event_length_post = 3 // length of event window post event (days)

			scalar est_length = 100000 // length of estimation window (days)
			scalar earliest_date = 20080314 // earliest date for estimation window
						
			scalar reg_type = 1 // 1: constant mean return 2: statistical market model 3: wrong model 
			
			scalar show_days = 1 // 1: show not only pre / post estimations but also every single day

	 quietly do event_study

*** Postestimation: Test significance
	quietly do post_estimation
	do significance
	//scalar list

		




*** Estudy command

	//estudy ln_return_eua, datevar(stata_date) evdate(20130416) lb1(3) ub1(3) dateformat(YMD) indexlist(ln_return_eua) modtype(HMM)

/*
// MSFE

	forvalues i = 0(1)9 {
		di "-----------------------------NEXT ONE-----------------------------------"
		di "reg 2013 + `i' to 2014 + `i'"
		
		reg mo1_px L.mo1_px $explanatory if year >= (2013 + `i') & 		year < (2014 + `i'), robust
		estimates store reg`i'
		
		capture drop resids_within_`i'
		predict double resids_within_`i' if year >= (2013 + `i') & year < (2014 + `i'), residuals
		capture drop resids_within_sqr_`i'
		gen resids_within_sqr_`i' = resids_within_`i'^2
		summ resids_within_sqr_`i'
		scalar MSFE_within_`i' = r(mean)
		
		capture drop resids_out_`i'
		predict double resids_out_`i' if year > (2013 + `i'), residuals
		capture drop resids_out_sqr_`i'
		gen resids_out_sqr_`i' = resids_out_`i'^2
		summ resids_out_sqr_`i'
		scalar MSFE_out_`i' = r(mean)
	}

	esttab reg0 reg1 reg2 reg3 reg4
	esttab reg5 reg6 reg7 reg8 reg9


	forvalues i = 0(1)100 {
		di "-----------------------------NEXT ONE-----------------------------------"
		
		reg mo1_px L.mo1_px $explanatory if date >= 20080401 & date <= 20090430, robust

		
		
	}
*/
