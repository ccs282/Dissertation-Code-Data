
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
	quietly do data_prep

*** DATA DESCRIPTIVE
	quietly do data_descriptive
		
*** GENERATE (AB)NORMAL RETURNS

	** Define scalars/matrices

		* Test one specific date only (independent of country exit dates)
			scalar test_specific_date = "n" // "yes" when determining one specific date only; must be unequal "yes" when analysing countries' coal phase-outs

			scalar date_specific = 20220707 // determine date to be tested if test_specific_date == "yes"

		* Phase out announcements
			quietly do phase_out

				
		* Event Study Settings
			scalar event_length_pre = 3 // length of event window pre event (days)
			scalar event_length_post = 3 // length of event window post event (days)

			scalar est_length = 255 // length of estimation window (days)
			scalar earliest_date = 20080314 // earliest date for estimation window
						
			scalar reg_type = 1 // 1: constant mean return 2: zero mean return 3: model with many explanatory variables 3.1: log returns for all variables 3.2: for all D_
			
			scalar show_days = 1 // 1: show not only pre / post estimations but also every single day
			
			scalar price = "yes"
			scalar volume = "n"


	quietly do event_study

*** Postestimation: Test significance
	quietly do post_estimation
	do significance
	
	
*** Formatted Output
	//do output

	/*
	do lets_go_loop
	*/
/*	
foreach var of varlist eua oil coal gas elec gsci vix stoxx diff_baa_aaa ecb_spot_3m{
	dfuller `var'
	scalar dfuller_`var' = r(p)
	kpss `var' 
	
}

//quick convert log returns --> normal returns: 
scalar convert = 0.064
di exp(convert) - 1

foreach var of varlist ln_return_eua D_ln_return_eua ln_return_oil D_ln_return_oil ln_return_coal D_ln_return_coal ln_return_gas D_ln_return_gas ln_return_elec D_ln_return_elec ln_return_gsci D_ln_return_gsci ln_return_vix D_ln_return_vix ln_return_stoxx D_ln_return_stoxx ln_return_diff_baa_aaa D_ln_return_diff_baa_aaa ln_return_ecb_spot_3m  D_ln_return_ecb_spot_3m {
	dfuller `var' if year > 2014
	scalar dfuller_`var' = r(p)
	kpss `var' if year > 2014
}

foreach var of varlist ln_return_coal D_ln_return_coal ln_return_gas D_ln_return_gas {
	kpss `var' 
}

// problematic (KPSS) for full sample: coal**; gas*
// problematic for greater than 2019: oil*; GSCI**; STOXX*; 

foreach var of global ln_return_explanatory {
	xcorr 
}
xcorr ln_return_coal ln_return_gas, table lags(0)
pwcorr ln_return_oil ln_return_coal ln_return_gas ln_return_elec D_ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m, star(0.05)


// ln_return_oil ln_return_coal ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m
/*	
foreach var of varlist oil coal gas elec gsci vix stoxx diff_baa_aaa ecb_spot_3m{
	summ ln_return_`var' if date > 20080313 & date < 20140501, d
}

tabstat ln_return_eua ln_return_oil ln_return_coal D_ln_return_coal ln_return_gas D_ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m if date > 20080313 & date <= 20220714, stat(mean sd min max skewness kurtosis)

asdoc tabstat ln_return_eua ln_return_oil ln_return_coal D_ln_return_coal ln_return_gas D_ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m if date > 20080313 & date <= 20220714, stat(mean sd min max skewness kurtosis N var cv median semean) dec(4) 



foreach var of varlist eua oil coal gas elec gsci vix stoxx diff_baa_aaa ecb_spot_3m ln_return_eua D_ln_return_eua ln_return_oil D_ln_return_oil ln_return_coal D_ln_return_coal ln_return_gas D_ln_return_gas ln_return_elec D_ln_return_elec ln_return_gsci D_ln_return_gsci ln_return_vix D_ln_return_vix ln_return_stoxx D_ln_return_stoxx ln_return_diff_baa_aaa D_ln_return_diff_baa_aaa ln_return_ecb_spot_3m  D_ln_return_ecb_spot_3m {
	di "`var'"
	count if `var' == .
}



capture drop missing
gen missing = 0 
replace missing = 1 if ln_return_ecb_spot_3m == .
ttable2 ln_return_eua ln_return_oil ln_return_coal ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa, by(missing)


capture drop missing
gen missing = 0 
replace missing = 1 if ln_return_elec == .
ttable2 ln_return_eua ln_return_oil ln_return_coal ln_return_gas ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m, by(missing)


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
	
	scalar est_length = 5000
	scalar no_windows = 479000 // max lies at approx 479 currently
	scalar price = "yes"
	scalar volume = "n"
	quietly do forecast_errors
/*
	capture drop length
	capture drop vrb
	capture drop cm
	gen vrb = .
	gen length = .
	gen cm = .
	forvalues a = 15(10)3500 {
		scalar est_length = `a'
		quietly do forecast_errors
		replace length = `a' if _n == `a'
		summ RMSFE_variables, meanonly
		replace vrb = r(mean) if _n == `a'
		summ RMSFE_const_mean, meanonly
		replace cm = r(mean) if _n == `a'
		di "`a'"
	}

twoway line vrb cm length if length < 500
*/

	scalar earliest_year = 2007
	scalar latest_year = 2022
	foreach y in MSFE RMSFE MAFE {
		tabstat `y'_variables `y'_variables_2 `y'_variables_3 `y'_const_mean `y'_const_mean_trim `y'_zero_mean `y'_levels if year >= earliest_year & year <= latest_year, stat(mean sd min max skewness kurtosis)
	}
	

	foreach y in MSFE RMSFE MAFE {
		local earliestyear = earliest_year
		local latestyear = latest_year
		local estimation_length = est_length
		if "`y'" == "MSFE" {
			asdoc tabstat `y'_variables `y'_variables_2 `y'_variables_3 `y'_const_mean `y'_const_mean_trim `y'_zero_mean `y'_levels if year >= earliest_year & year <= latest_year, stat(mean sd min max skewness kurtosis) replace dec(4) save(`estimation_length'_`earliestyear'_`latestyear'.doc)
		}
		else {
			asdoc tabstat `y'_variables `y'_variables_2 `y'_variables_3 `y'_const_mean `y'_const_mean_trim `y'_zero_mean `y'_levels if year >= earliest_year & year <= latest_year, stat(mean sd min max skewness kurtosis) dec(4) save(`estimation_length'_`earliestyear'_`latestyear'.doc) append
		}
	}


	foreach y in MSFE RMSFE MAFE {
		foreach x in variables const_mean const_mean_trim zero_mean {
			di "-------------start-------------"
			di "`y'_`x'"
			trimmean `y'_`x' if year >= earliest_year & year <= latest_year, percent(5)
			di "-------------end--------------"
		}
	}	

	
	
	twoway line RMSFE_variables_2 stata_date if year >= earliest_year & year <= latest_year, xlabel(, angle(vertical))
	
		twoway line RMSFE_levels stata_date if year > 2008 & year < 2023, xlabel(, angle(vertical))


	twoway line ln_return_eua yhat_variables yhat_const_mean stata_date if year > 2012 & year < 2014, xlabel(, angle(vertical))
	

	
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

 reg ln_return_eua L.ln_return_eua L2.ln_return_eua L3.ln_return_eua $ln_return_explanatory if est_win == 1, robust
 
 estat ic

 	
	capture confirm variable cool
	di _rc
	if !_rc {
		di "yes"
	}
	else {
		di "no"
	}
	
	
	
	
	matrix test = uk_leak1_phases\uk_main1_phases
	matrix list uk_leak1_phases
	
	matrix list uk_main1_phases
	asdoc matlist test, replace
	
	matlist test
	matrix test = J(3, 3, .)
	
	matrix test2 = test\uk_main1_phases
	matrix list test2
	
	
	
	
*/

/*
import delimited "Trading_volume_test.csv", clear

forvalues i = 10(1)21 {
	capture drop dominant_`i'
	gen dominant_`i' = .
	local temp = `i'+1
	replace dominant_`i' = 1 if moz`i'comdty > moz`temp'comdty
	replace dominant_`i' = 0 if moz`i'comdty < moz`temp'comdty
	order dominant_`i', after(moz`i'comdty)
	capture drop date_`i'
	gen date_`i' = dates
	order date_`i', after(dominant_`i')
}

keep dates dominant* moz*

mean ln_return_eua
trimmean ln_return_eua if year > 2015, percent(5)

*/