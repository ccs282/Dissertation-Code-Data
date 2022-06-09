*** SET WD

cd "C:\Users\jonas\OneDrive - London School of Economics\Documents\LSE\GY489_Dissertation\LETS GO\Dissertation-Code-Data"

*** IMPORT DATA
clear all
import delimited "Data.csv"


*** PREP DATA
d
	
	** explanatory variables 
	local explanatory oil_last coal_last gas_last elec_last gsci vix stoxx diff_baa_aaa cer_last ecb_spot_3m

	foreach var of local explanatory {
		capture drop ln_`var'
		gen ln_`var' = ln(`var')
	}

	local ln_explanatory ln_oil_last ln_coal_last ln_gas_last ln_elec_last ln_gsci ln_vix ln_stoxx ln_diff_baa_aaa ln_cer_last ln_ecb_spot_3m

	capture drop ln_eua_settle
	gen ln_eua_settle = ln(eua_settle)



	** Prep time series

	drop if date <= 20080314 // Koch et al. (2014)	

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

	local D_ln_explanatory D.ln_oil_last D.ln_coal_last D.ln_gas_last D.ln_elec_last D.ln_gsci D.ln_vix D.ln_stoxx D.ln_diff_baa_aaa D.ln_cer_last D.ln_ecb_spot_3m

	** Create lagged dependent variable
	
	/*
	forvalues i=1(1)100 {
		capture drop eua_settle_lag`i'
		gen eua_settle_lag`i' = .
		replace eua_settle_lag`i' = eua_settle[_n-`i']
	}
		//capture drop eua_settle_lag*
	*/

*** DATA DESCRIPTIVE

/*
xcorr mo1_px_last co1_px_last 
xcorr gsci_px_last diff_baa_aaa 
xcorr tzt1_px_last co1_px_last 
*/

*** GENERATE (AB)NORMAL RETURNS


/*
reg mo1_px_settle $explanatory, robust
reg mo1_px_last mo1_px_last_lag60 $explanatory, robust
reg mo1_px_settle L60.mo1_px_last $explanatory, robust
reg mo1_px_settle $explanatory, robust

reg mo1_px_settle $explanatory_ln_D, robust
reg D.mo1_px_settle_ln $explanatory_ln_D, robust
*/

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
	
	scalar year_IT = 2021
scalar month_IT = 7
scalar day_IT = 15

scalar event_length = 3
scalar estimation_length = 1000
scalar earliest_date = 20080314

scalar reg_type = 1
/*
1: reg settle AR1 + explanatory
2: reg settle D.L.AR1_ln + D.explanatory_ln; without ECB 
*/

	// event time
capture drop italy_announce
gen italy_announce = .
replace italy_announce = 1 if year == year_IT & month == month_IT & day == day_IT

	// event window
capture drop italy_event_window
gen italy_event_window = .
summ trading_date if italy_announce == 1
replace italy_event_window = 1 if (trading_date >= r(mean) - event_length) & (trading_date <= r(mean) + event_length)

	// estimation window
capture drop italy_estimation_window
gen italy_estimation_window = .
summ trading_date if italy_announce == 1
replace italy_estimation_window = 1 if (trading_date >= r(mean) - event_length - estimation_length) & (trading_date < r(mean) - event_length)

	// normal returns
if reg_type == 1 {
	reg mo1_px_settle L.mo1_px_settle $explanatory if italy_estimation_window == 1 & date >= earliest_date, robust
}

if reg_type == 2 {
	reg mo1_px_settle L.mo1_px_settle D.co1_px_last_ln D.xa1_px_last_ln D.tzt1_px_last_ln D.gi1_px_last_ln D.vix_px_last_ln D.stoxx_px_last_ln D.diff_baa_aaa_ln D.car1_px_last_ln D.gsci_px_last_ln if italy_estimation_window == 1, robust
}

capture drop p
predict p
capture drop normal_return_IT
gen normal_return_IT = .
replace normal_return_IT = p if italy_event_window == 1
order normal_return_IT, after(mo1_px_settle)
capture drop p

	//abnormal returns
capture drop abnormal_return_IT
gen abnormal_return_IT = mo1_px_settle - normal_return_IT if italy_event_window == 1

capture drop abnormal_return_IT_perc
gen abnormal_return_IT_perc = abnormal_return_IT/normal_return_IT

capture drop cum_abnormal_return_IT 
// wouldn't sum be correct?!
egen cum_abnormal_return_IT = total(abnormal_return_IT)
di cum_abnormal_return_IT[1]
order abnormal_return_IT abnormal_return_IT_perc, after(normal_return_IT)

summ trading_date if italy_announce == 1

	// test significance of 
capture drop abnormal_return_IT_SD
egen abnormal_return_IT_SD = sd(abnormal_return_IT)
capture drop test_IT 
gen test_IT = (1/sqrt(2*event_length+1))*(cum_abnormal_return_IT[1]/abnormal_return_IT_SD[1])
di abs(test_IT[1])

summ abnormal_return_IT

quietly summ abnormal_return_IT_perc if year == year_IT & month == month_IT & day == day_IT

di"----------------------------------"
di "change event day in %"
quietly summ abnormal_return_IT_perc if year == year_IT & month == month_IT & day == day_IT
di r(mean)
di"----------------------------------"
di "change pre-event in %"
quietly summ trading_date if italy_announce == 1
quietly summ abnormal_return_IT_perc if (trading_date >= r(mean) - event_length) & (trading_date < r(mean))
di r(mean)*event_length
di"----------------------------------"
di "change post-event in %"
quietly summ trading_date if italy_announce == 1
quietly summ abnormal_return_IT_perc if (trading_date > r(mean)) & (trading_date <= r(mean) + event_length)
di r(mean)*event_length
di"----------------------------------"
di "change event window in %"
quietly summ trading_date if italy_announce == 1
quietly summ abnormal_return_IT_perc if (trading_date >= r(mean) - event_length) & (trading_date <= r(mean) + event_length)
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

