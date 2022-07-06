
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
				
				scalar date_specific = 20190128 // determine date to be tested if test_specific_date == "yes"

				
		* Event Study Settings
			scalar event_length_pre = 3 // length of event window pre event (days)
			scalar event_length_post = 3 // length of event window post event (days)

			scalar est_length = 255 // length of estimation window (days)
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

tabstat ln_return_eua ln_return_oil ln_return_coal ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m if date > 20080313 & date < 20140501, stat(mean sd sk k min max)


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

	*/
	

*** MSFE, RMSFE, MAFE
	
	capture drop MSFE
	capture drop RMSFE
	capture drop MAFE
	capture drop NR_*
	capture drop yhat*

	forvalues k = 0(7)210000{
			
		** estimation window + event window for forecast error
		capture drop event_date_fe
		gen event_date_fe = .
		summ trading_date if date == 20090403
		replace event_date_fe = 1 if trading_date == r(mean) + `k'

		capture drop ew_fe
		gen ew_fe = .
		summ trading_date if event_date_fe == 1
		replace ew_fe = 1 if (trading_date >= r(mean) - event_length_pre) & (trading_date <= r(mean) + event_length_post)

		capture drop est_win_fe
		gen est_win_fe = .
		summ trading_date if event_date_fe == 1
		replace est_win_fe = 1 if (trading_date >= r(mean) - event_length_pre - est_length) & (trading_date < r(mean) - event_length_pre) & (date >= 20080401)
		
		foreach x in variables const_mean zero_mean{
			
			** generate predictions
			if  "`x'" == "variables" {
				capture drop tempv 
				summ trading_date if event_date_fe == 1
				gen tempv = ln_return_eua if trading_date < (r(mean) - event_length_pre) 
				reg tempv L.tempv $ln_return_explanatory if est_win_fe == 1, robust

				local ew_length = event_length_post + event_length_pre + 1
				forvalues i = 1(1)`ew_length' {
					summ trading_date if event_date_fe == 1
					predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
					replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
					capture gen NR_`x'= .
					replace NR_`x' = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
				}
			}

			else if "`x'" == "const_mean" {
				reg ln_return_eua est_win_fe if est_win_fe == 1, robust noconst
				gen NR_`x' = e(b)[1, 1]
			}

			else if "`x'" == "zero_mean" {
				gen NR_`x' = 0

			}

			** yhat, MSFE, RMSFE, MAFE

			capture gen yhat_`x' = . 
			replace yhat_`x' = NR_`x' if ew_fe == 1
				
			capture drop NR_*

			capture drop fe_`x' 
			gen fe_`x' = yhat_`x' - ln_return_eua if ew_fe == 1

			capture drop fe_abs_`x'
			gen fe_abs_`x' = abs(fe_`x')

			capture drop fe_squared_`x'
			gen fe_squared_`x' = fe_`x'^2

			capture gen MSFE_`x' = .
			summ fe_squared_`x'
			replace MSFE_`x' = r(mean) if event_date_fe == 1

			capture gen RMSFE_`x' = .
			replace RMSFE_`x' = sqrt(MSFE_`x')

			capture gen MAFE_`x' = .
			summ fe_abs_`x'
			replace MAFE_`x' =  r(mean) if event_date_fe == 1
			
			capture drop fe*
		}
	}
	
	

foreach y in MSFE RMSFE MAFE {
	tabstat `y'_variables `y'_const_mean, stat(mean sd min max sk k)
}

		
twoway line RMSFE_variables RMSFE_const_mean stata_date if year > 2014, xlabel(, angle(vertical))

twoway line ln_return_eua yhat_variables yhat_const_mean stata_date if year < 2020 & year > 2018, xlabel(, angle(vertical))
	

	
/*
	forvalues i = 0(1)100 {
		di "-----------------------------NEXT ONE-----------------------------------"
		
		reg mo1_px L.mo1_px $explanatory if date >= 20080401 & date <= 20090430, robust

		
		
	}
*/

/*
reg ln_return_eua L.ln_return_eua $ln_return_explanatory if est_win == 1, robust

tsset stata_date

/*
save, replace
rolling, window(7) stepsize(100): reg ln_return_eua L.ln_return_eua $ln_return_explanatory, robust
*/


foreach var of global ln_return_explanatory {
	codebook `var'
}

forvalues i=2009(1)2021{
	count if year == `i'
	global trading_days_`i' = r(N)
	gen xxx_`i' = r(N)
}

capture drop year_obs
egen year_obs = rowmean(xx*)
di year_obs[1]
*/

