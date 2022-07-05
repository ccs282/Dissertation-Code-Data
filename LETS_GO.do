
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

		* Phase out announcements
			quietly do phase_out

			matrix list announce_date
			
		* Which dates to analyse?
			
			* Test one specific date only (independent of country exit dates)
				scalar test_specific_date = "yes" // "yes" when determining one specific date only; must be unequal "yes" when analysing countries' coal phase-outs


			* Test coal phase-out dates from matrix 
				scalar Germany_num = 		1 // 0-4
				scalar UK_num = 			0 // 0-3
				scalar Spain_num = 			0 // 0-4
				scalar Italy_num = 			0 // 0-2
				scalar Czech_Republic_num = 0 // 0-2
				scalar Netherlands_num = 	0 // 0-3
				scalar France_num = 		1 // 0-3
				scalar Romania_num = 		0 // 0-3
				scalar Bulgaria_num = 		0 // 0-1
				scalar Greece_num = 		0 // 0-3
				scalar Others_num = 		0 // 0-?
				
				scalar date_specific = 20220107 // determine date to be tested if test_specific_date == "yes"

				
		* Event Study Settings
			scalar event_length_pre = 3 // length of event window pre event (days)
			scalar event_length_post = 3 // length of event window post event (days)

			scalar est_length = 250000 // length of estimation window (days)
			scalar earliest_date = 20080314 // earliest date for estimation window
						
			scalar reg_type = 3 // 1: constant mean return 2: zero mean return 3: model with many explanatory variables 
			
			scalar show_days = 1 // 1: show not only pre / post estimations but also every single day


	 quietly do event_study

*** Postestimation: Test significance
	quietly do post_estimation
	do significance
	//scalar list

	
/*	
foreach var of varlist eua oil coal gas elec gsci vix stoxx diff_baa_aaa ecb_spot_3m{
	dfuller `var'
}


foreach var of varlist ln_return_eua ln_return_oil ln_return_coal ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m {
	dfuller `var' 
}


/*	
foreach var of varlist oil coal gas elec gsci vix stoxx diff_baa_aaa ecb_spot_3m{
	summ ln_return_`var' if date > 20080313 & date < 20140501, d
}

tabstat ln_return_eua ln_return_oil ln_return_coal ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m if date > 20080313 & date < 20140501, s(mean sd sk k max min)


capture drop missing
gen missing = 0 
replace missing = 1 if ln_return_ecb_spot_3m == .
ttable2 ln_return_eua ln_return_oil ln_return_coal ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa, by(missing)


twoway line ln_return_ecb_spot_3m stata_date, xlabel(, angle(vertical))

// gas, vix, ecb_spot_3m, cer

forvalues i=1(1)5 {
	di "`i'"
}
*/


*** Estudy command

	//estudy ln_return_eua, datevar(stata_date) evdate(20130416) lb1(3) ub1(3) dateformat(YMD) indexlist(ln_return_eua) modtype(HMM)

/*
// MSFE

	forvalues i = 0(1)7 {
		di "-----------------------------NEXT ONE-----------------------------------"
		di "reg 2013 + `i' to 2014 + `i'"
		
		reg ln_return_eua L.ln_return_eua $ln_return_explanatory if year >= (2013 + `i') & year < (2014 + `i'), robust
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
	esttab reg5 reg6 reg7
*/
/*
	forvalues i = 0(1)100 {
		di "-----------------------------NEXT ONE-----------------------------------"
		
		reg mo1_px L.mo1_px $explanatory if date >= 20080401 & date <= 20090430, robust

		
		
	}
*/
