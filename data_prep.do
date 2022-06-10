
** explanatory variables 
	
	global explanatory oil_last coal_last gas_last elec_last gsci vix stoxx diff_baa_aaa cer_last ecb_spot_3m

	foreach var of global explanatory {
		capture drop ln_return_`var'
		gen ln_return_`var' = ln(`var'[_n] / `var'[_n - 1]) if _n != 1
	}

	global ln_return_explanatory ln_return_oil_last ln_return_coal_last ln_return_gas_last ln_return_elec_last ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_cer_last ln_return_ecb_spot_3m
	
	
	capture drop aaa baa
	
** explained/dependent variable
	
	capture drop ln_return_eua_settle
	gen ln_return_eua_settle = .
	replace ln_return_eua_settle = ln(eua_settle[_n] / eua_settle[_n - 1]) if _n != 1
		
	order ln_return_eua_settle, after(eua_settle)
	
	* Create lagged dependent variable
		/*
		forvalues i=1(1)5 {
			capture drop ln_return_eua_settle_lag`i'
			gen ln_return_eua_settle_lag`i' = .
			replace ln_return_eua_settle_lag`i' = ln_return_eua_settle[_n-`i'] if _n != 1
		}
		//capture drop eua_settle_lag*
		*/


** Prep time series

	drop if date <= 20080403 // Koch et al. (2014) use 20080314; but there's a jump in EUA prices on April 2 in my data

	capture drop year month day stata_date
	gen year = int(date/10000) 
	gen month = int((date-year*10000)/100) 
	gen day = int((date-year*10000-month*100)) 
	gen stata_date = mdy(month,day,year)
	order stata_date, after(date)
	format stata_date  %td

	capture drop trading_date
	gen trading_date = 1
	replace trading_date = trading_date[_n-1] + 1 if _n != 1 // there are missing dates (weekends etc.)

	tsset trading_date, d

** Create lagged dependent variable
	
	/*
	forvalues i=1(1)100 {
		capture drop eua_settle_lag`i'
		gen eua_settle_lag`i' = .
		replace eua_settle_lag`i' = eua_settle[_n-`i'] if _n != 1
	}
		//capture drop eua_settle_lag*
	*/

