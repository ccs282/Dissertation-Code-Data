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
			capture drop ln_return_`var'
			gen ln_return_`var' = ln(`var'[_n] / `var'[_n - 1]) if _n != 1
		}

		global ln_return_explanatory ln_return_oil_last ln_return_coal_last ln_return_gas_last ln_return_elec_last ln_return_gsci ln_return_vix ln_return_stoxx ln_return_diff_baa_aaa ln_return_cer_last ln_return_ecb_spot_3m
	
	// transform interest rate bc of negative values?
	
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
	
		summ ln_return_eua_settle if date >= 20071003 & date <= 20140205 // compare to Deeney et al. (2016); mean -0.000815; SD 0.03294; min -0.43208; max 0.24525; obs 1625
		
		summ ln_return_eua_settle if date >= 20080324 & date <= 20121019 // compare to Kemden et al. (2016); mean −0.000866; SD 0.026732; min −0.116029; max 0.245247; obs 1194
		
		summ ln_return_eua_settle if date >= 20080314 & date <= 20120430 // compare to Koch et al. (2014); mean -0.23 [-.00088123 daily]; SD 0.56 [.03466313 daily]; annualised values!!! for log returns, divide by 261; for SD divide by sqrt(261); assume 261 trading days (my calcuations)
		di -0.23/261
		di 0.56/sqrt(261)
	
		* explanatory variables
		
			foreach var of global ln_return_explanatory { 
				summ `var' if date >= 20080314 & date <= 20120430 // compare to Koch et al. (2014)
				di "mean `var':"
				di r(mean)*261
				di "SD `var':"
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
	
			scalar date_test = 20190128

		* Event Study parameters
			scalar event_length = 3 // days
			scalar est_length = 1000 // days
			scalar earliest_date = 20080314 // earliest date for estimation win
						
			scalar reg_type = 3 // 1: constant mean return 2: statistical market model 3: wrong model 

	** Event time
		capture drop event_date
		gen event_date = .
		replace event_date = 1 if date == date_test 

	** Event win
		capture drop event_win
		gen event_win = .
		summ trading_date if event_date == 1
		replace event_win = 1 if (trading_date >= r(mean) - event_length) & (trading_date <= r(mean) + event_length)

	** Estimation win
		capture drop est_win
		gen est_win = .
		summ trading_date if event_date == 1
		replace est_win = 1 if (trading_date >= r(mean) - event_length - est_length) & (trading_date < r(mean) - event_length)

	** Normal returns
	
		if reg_type == 1 {
		}

		if reg_type == 2 {
			reg ln_return_eua_settle L.ln_return_eua_settle $ln_return_explanatory if est_win == 1 & date >= earliest_date, robust
		}

		if reg_type == 3 {
			reg eua_settle L.eua_settle $explanatory if est_win == 1 & date >= earliest_date, robust
		}
		
	// add constant mean return!!

		capture drop NR
		predict NR
		
		order NR, after(ln_return_eua_settle) 

	** Abnormal returns
		if reg_type == 3 {
			capture drop AR
			gen AR = eua_settle - NR 
			
			capture drop AR_perc
			gen AR_perc = AR/NR
			order AR AR_perc, after(NR)
		}
		
		else {
			capture drop AR
			gen AR = ln_return_eua_settle - NR
			order AR, after(NR)
		}

	** Cumulative abnormal returns
	
		capture drop CAR*

		* Event window
			egen CAR_event_win_ = total(AR) if event_win == 1
			summ CAR_event_win_
			scalar CAR_event_win = r(mean)
			di CAR_event_win

		* Pre-event
			egen CAR_pre_ = total(AR) if event_win == 1 & date < date_test
			summ CAR_pre_
			scalar CAR_pre = r(mean)

		* Post-event
			egen CAR_post_ = total(AR) if event_win == 1 & date > date_test
			summ CAR_post_
			scalar CAR_post = r(mean)

		* Event Day
			egen CAR_event_ = total(AR) if event_date == 1
			summ CAR_event_
			scalar CAR_event = r(mean)
			di CAR_event
		
*** Postestimation: Test significance
	
	** Variance & SD AR (estimation win)
	
		capture drop AR_squared
		capture drop TSS
		gen AR_squared = .
		replace AR_squared = AR^2 if est_win == 1
		egen TSS = total(AR_squared) if est_win == 1
		summ TSS
		scalar TSS_aux = r(mean)
		summ trading_date if est_win == 1
		scalar var_AR = (1/(r(max)-r(min)-2))*TSS_aux
		scalar SD_AR = sqrt(var_AR)
		capture drop AR_squared TSS 
		di var_AR
		di SD_AR
	
	** Variance & SD CAR (event window)

		* Full Event window
			scalar var_CAR_event_win = (2*event_length+1)*var_AR
			scalar SD_CAR_event_win = sqrt(var_CAR_event_win)
			di var_CAR_event_win
			di SD_CAR_event_win

		* Pre-event & Post-event
			scalar var_CAR_prepost = event_length*var_AR
			scalar SD_CAR_prepost = sqrt(var_CAR_prepost)
			di var_CAR_prepost
			di SD_CAR_prepost

		* Event Day
			scalar var_CAR_event = var_AR
			scalar SD_CAR_event = sqrt(var_CAR_event)
			di var_CAR_event
			di SD_CAR_event

	** Variance & SD avg CAR (event window; across different dates)
	
	
	** Test statistical significance
		scalar df = 950
		scalar level = 0.05
		scalar cv = invttail(df, level/2)
	
		* Event day
			scalar t_stat = CAR_event/SD_CAR_event
			di t_stat
	
	
			scalar p_value = ttail(df ,abs(_b[_cons]/_se[_cons]))*2





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
	di "change event win in %"
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

