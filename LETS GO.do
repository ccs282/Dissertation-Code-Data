*** SET WD

cd "C:\Users\jonas\OneDrive - London School of Economics\Documents\LSE\GY489_Dissertation\LETS GO\Dissertation-Code-Data"

*** IMPORT DATA
clear all
import delimited "Data.csv"

/*
Wrong Data:
- EUA december ahead needed; currently MO1 used
- offset prices same
- check oil coal gas elec
*/


*** PREP DATA
d
	
	** explanatory variables 
	global explanatory oil_last coal_last gas_last elec_last gsci vix stoxx diff_baa_aaa cer_last ecb_spot_3m

	foreach var of global explanatory {
		capture drop ln_`var'
		gen ln_`var' = ln(`var')
	}

	global ln_explanatory ln_oil_last ln_coal_last ln_gas_last ln_elec_last ln_gsci ln_vix ln_stoxx ln_diff_baa_aaa ln_cer_last ln_ecb_spot_3m

	foreach var of global ln_explanatory {
		capture drop `var'_return
		gen `var'_return = .
		replace `var'_return = `var'[_n] - `var'[_n - 1] if _n != 1
	}
	
	global ln_explanatory_return ln_oil_last_return ln_coal_last_return ln_gas_last_return ln_elec_last_return ln_gsci_return ln_vix_return ln_stoxx_return ln_diff_baa_aaa_return ln_cer_last_return ln_ecb_spot_3m_return
	
	capture drop aaa baa
	
	** explained/dependent variable
	capture drop ln_eua_settle
	gen ln_eua_settle = ln(eua_settle)
	
	capture drop ln_eua_settle_return
	gen ln_eua_settle_return = .
	replace ln_eua_settle_return = ln_eua_settle[_n] - ln_eua_settle[_n - 1] if _n != 1
	order ln_eua_settle_return, after(eua_settle)
	
		* Create lagged dependent variable
	
		
		forvalues i=1(1)5 {
			capture drop ln_eua_settle_return_lag`i'
			gen ln_eua_settle_return_lag`i' = .
			replace ln_eua_settle_return_lag`i' = ln_eua_settle_return[_n-`i'] if _n != 1
		}
			//capture drop eua_settle_lag*
		


	** Prep time series

	//drop if date <= 20080314 // Koch et al. (2014)	

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

*** DATA DESCRIPTIVE

	** mean log returns
	
	summ ln_eua_settle_return if date >= 20071003 & date <= 20140205 // compare to Deeney et al. (2016); mean -0.000815; SD 0.03294; min -0.43208; max 0.24525; obs 1625
	
	summ ln_eua_settle_return if date >= 20080324 & date <= 20121019 // compare to Kemden et al. (2016); mean −0.000866; SD 0.026732; min −0.116029; max 0.245247; obs 1194
	
	summ ln_eua_settle_return if date >= 20080314 & date <= 20120430 // compare to Koch et al. (2014); mean -0.23; SD 0.56; annualised values!!! for log returns, divide by 261; for SD divide by sqrt(261); assume 261 trading days (my calcuations)
	
		* explanatory variables
		foreach var of global ln_explanatory_return { 
			summ `var' if date >= 20080314 & date <= 20120430 // compare to Koch et al. (2014)
			di "mean:"
			di r(mean)*261
			di "SD:"
			di r(sd)*sqrt(261)
		}
		
		
		
	/*count if date >= 20080314 & date <= 20090313
	count if date >= 20090314 & date <= 20100313
	count if date >= 20100314 & date <= 20110313
	count if date >= 20110314 & date <= 20120313
	count if date >= 20120314 & date <= 20130313
	count if date >= 20130314 & date <= 20140313*/
	
		
	** xcorr?
	/*
	xcorr mo1_px_last co1_px_last 
	xcorr gsci_px_last diff_baa_aaa 
	xcorr tzt1_px_last co1_px_last 
	*/

*** GENERATE (AB)NORMAL RETURNS


	** Define scalars/matrices

		* Phase out announcements
		
		matrix def announce_date = (20190128, 20180915, 20200116, 20211015, .\ 20151118, 20180105, 20201214, ., .\ 20181115, 20190222, 20200120, 20210630, . \ 20171024, 20190923, ., ., . \ 20201204, 20220107, ., ., . \ 20171010, 20160923, 20180518, ., . \ 20161115, 20160426, 20170706, ., . \ 20210526, 20210603, 20220531, ., . \ 20211011, ., ., ., . \ 20190923, 20210923, 20220406, ., . \ ., ., ., ., .)
		
		matrix rown announce_date = 1_Germany 2_UK 3_Spain 4_Italy 5_Czech_Republic 6_Netherlands 7_France 8_Romania 9_Bulgaria 10_Greece 11_Others
		matrix coln announce_date = Date_Pref Date2 Date3 Date4 Date5
		
		matrix list announce_date
		
		/*
		NOTES
		
		Generally: 1st date is the preferred date
		
		1 (Germany): 
			1st date 20190128: should be 26 Jan 2019, 28 Jan is the next trading date
			2nd date :
		2 (UK):
		3 (Spain):
		4 (Italy):
		5 (Czech_Republic):
		6 (Netherlands):
		7 (France):
		8 (Romania):
		9 (Bulgaria):
		10 (Greece):
		11 (Others): 
		
		*/
		* Specific date
	
		scalar date_test = 20210715

		* Event Study parameters
		scalar event_length = 3 // days
		scalar est_length = 1000 // days
		scalar earliest_date = 20080314 // earliest date for estimation window
		
		scalar CAR_type = "event_window" // change to "event_window", "pre-event", "event", "post-event"
		
		scalar reg_type = 1 // 1: constant mean return 2: statistical market model
		/*
		Notes reg_type
		1: reg EUA_settle AR1 explanatory
		2: XXX
		*/

	** Event time
	capture drop event_date
	gen event_date = .
	replace event_date = 1 if date == date_test 

	** Event window
	capture drop event_window
	gen event_window = .
	summ trading_date if event_date == 1
	replace event_window = 1 if (trading_date >= r(mean) - event_length) & (trading_date <= r(mean) + event_length)

	** Estimation window
	capture drop est_window
	gen est_window = .
	summ trading_date if event_date == 1
	replace est_window = 1 if (trading_date >= r(mean) - event_length - est_length) & (trading_date < r(mean) - event_length)

	** Normal returns
	// probably wrong; use log returns?
	if reg_type == 1 {
		reg eua_settle L.eua_settle $explanatory if est_window == 1 & date >= earliest_date, robust
	}

	/*
	reg ln_eua_settle_return L.ln_eua_settle_return $ln_explanatory_return if year > 2013 & year < 2020, robust
	
		reg ln_eua_settle_return L.ln_eua_settle_return if year >2013 & year < 2020, robust
*/


	// add constant mean return!!

	/*
	if reg_type == 2 {
		reg mo1_px_settle L.mo1_px_settle D.co1_px_last_ln D.xa1_px_last_ln D.tzt1_px_last_ln D.gi1_px_last_ln D.vix_px_last_ln D.stoxx_px_last_ln D.diff_baa_aaa_ln D.car1_px_last_ln D.gsci_px_last_ln if italy_est_window == 1, robust
	}
	*/

	capture drop NR
	predict NR
	
	order NR, after(eua_settle) // change dependent

	** Abnormal returns
	capture drop AR
	gen AR = eua_settle - NR // change dependent

	capture drop AR_perc
	gen AR_perc = AR/NR
	order AR AR_perc, after(NR)
	
	/*
			scalar CAR_type = "event_window" // change to "event_window", "pre-event", "event", "post-event"
	*/
	
	capture drop CAR 
	egen CAR = total(AR) if event_window == 1
	gen CAR = sum(AR) if event_window == 1
	di CAR[1]

	summ trading_date if italy_announce == 1

	
*** Postestimation: Test significance
capture drop AR_SD
egen AR_SD = sd(AR)
capture drop test_IT 
gen test_IT = (1/sqrt(2*event_length+1))*(CAR[1]/AR_SD[1])
di abs(test_IT[1])

summ AR

quietly summ AR_perc if year == year_IT & month == month_IT & day == day_IT

di"----------------------------------"
di "change event day in %"
quietly summ AR_perc if year == year_IT & month == month_IT & day == day_IT
di r(mean)
di"----------------------------------"
di "change pre-event in %"
quietly summ trading_date if italy_announce == 1
quietly summ AR_perc if (trading_date >= r(mean) - event_length) & (trading_date < r(mean))
di r(mean)*event_length
di"----------------------------------"
di "change post-event in %"
quietly summ trading_date if italy_announce == 1
quietly summ AR_perc if (trading_date > r(mean)) & (trading_date <= r(mean) + event_length)
di r(mean)*event_length
di"----------------------------------"
di "change event window in %"
quietly summ trading_date if italy_announce == 1
quietly summ AR_perc if (trading_date >= r(mean) - event_length) & (trading_date <= r(mean) + event_length)
di r(mean)*(2*event_length+1)
di"----------------------------------"



// Estudy command


// MSFE

forvalues i = 0(1)9 {
	di "-----------------------------NEXT ONE-----------------------------------"
	di "reg 2013 + `i' to 2014 + `i'"
	
	reg mo1_px_settle L.mo1_px_settle $explanatory if year >= (2013 + `i') & 		year < (2014 + `i'), robust
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
	
	reg mo1_px_settle L.mo1_px_settle $explanatory if date >= 20080401 & date <= 20090430, robust

	
	
}

