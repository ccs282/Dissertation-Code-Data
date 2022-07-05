
** explanatory variables 
	
	global explanatory oil coal gas elec gsci vix stoxx diff_baa_aaa ecb_spot_3m

/*
	foreach var of global explanatory {
		capture drop ln_return_`var'
		gen ln_return_`var' = ln(`var'[_n] / `var'[_n - 1]) if _n > 1
	}
*/

	save data, replace

	foreach var of global explanatory {
		drop if `var' == .
		capture drop ln_return_`var'
		gen ln_return_`var' = ln(`var'[_n] / `var'[_n - 1]) if _n > 1
		save `var', replace
		use `var', clear
		keep ln_return_`var' date
		save, replace
		use data, clear
		// why not use date as matching variable?
		mmerge date using `var'
		drop _merge
		save data, replace
		erase "`var'.dta"
	}





	global ln_return_explanatory ln_return_oil ln_return_coal ln_return_gas ln_return_elec ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m

/*
	L.ln_return_oil L.ln_return_coal L.ln_return_gas L.ln_return_elec L.ln_return_gsci L.ln_return_vix L.ln_return_stoxx L.ln_return_diff_baa_aaa L.ln_return_cer L.ln_return_ecb_spot_3m
	*/

	capture drop aaa baa
	
** explained/dependent variable
	
	drop if eua == .
	capture drop ln_return_eua
	gen ln_return_eua = ln(eua[_n] / eua[_n - 1]) if _n > 1
	save eua, replace
	use eua, clear
	keep ln_return_eua date
	save, replace
	use data, clear
	// why not use date as matching variable?
	mmerge date using eua
	drop _merge
	save data, replace
	erase "eua.dta"


	order ln_return_eua, after(eua)
	
	* Create lagged dependent variable
		/*
		forvalues i=1(1)5 {
			capture drop ln_return_eua_lag`i'
			gen ln_return_eua_lag`i' = .
			replace ln_return_eua_lag`i' = ln_return_eua[_n-`i'] if _n != 1
		}
		//capture drop eua_lag*
		*/


** Prep time series

	drop if date <= 20080314 // same as Koch et al. (2016)
	//drop if date <= 20121231 // drop Phases I+II


	replace eua = . if eua == 0 // 6 wrong values

	* drop all observations that have a missing value for one of the explanatory variables or the dependent variable
		if treat_missing == 1 {
			drop if ln_return_oil == .| ln_return_coal == .| ln_return_gas == .| ln_return_elec == .| ln_return_gsci == .| ln_return_vix == .| ln_return_stoxx == .| ln_return_diff_baa_aaa == .| ln_return_ecb_spot_3m == .| ln_return_eua == .
		} 

		else if treat_missing == 2 {
			//
		}

		else if treat_missing == 3{
			//
		}


	capture drop year month day stata_date
	gen year = int(date/10000) 
	gen month = int((date-year*10000)/100) 
	gen day = int((date-year*10000-month*100)) 
	gen stata_date = mdy(month,day,year)
	order stata_date, after(date)
	format stata_date  %td

	// check if still at the right place after having dealt with missing values
	capture drop trading_date
	gen trading_date = 1
	replace trading_date = trading_date[_n-1] + 1 if _n != 1 // there are missing dates (weekends etc.)

	tsset trading_date, d

** Create lagged dependent variable
	
	/*
	forvalues i=1(1)100 {
		capture drop eua_lag`i'
		gen eua_lag`i' = .
		replace eua_lag`i' = eua[_n-`i'] if _n != 1
	}
		//capture drop eua_lag*
	*/

