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
				scalar test_specific_date = "no" // "yes" when determining one specific date only; must be unequal "yes" when analysing countries' coal phase-outs

				scalar date_specific = 20190128 // determine date to be tested if test_specific_date == "yes"

			* Test coal phase-out dates from matrix 
				scalar Germany_num = 2 // 0-4
				scalar UK_num = 0 // 0-3
				scalar Spain_num = 1 // 0-4
				scalar Italy_num = 1 // 0-2
				scalar Czech_Republic_num = 1 // 0-2
				scalar Netherlands_num = 1 // 0-3
				scalar France_num = 1 // 0-3
				scalar Romania_num = 1 // 0-3
				scalar Bulgaria_num = 1 // 0-1
				scalar Greece_num = 1 // 0-3
				scalar Others_num = 0 // 0-?

		* Event Study parameters
			scalar event_length = 3 // lenght of event window (days)
			scalar est_length = 1000 // length of estimation window (days)
			scalar earliest_date = 20080314 // earliest date for estimation window
						
			scalar reg_type = 1 // 1: constant mean return 2: statistical market model 3: wrong model 

	quietly do event_study
	//scalar list

*** Postestimation: Test significance
	
	** Variance & SD AR (estimation win)
		summ ln_return_eua_settle if est_win == 1

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
		
		* Pre-event
			scalar t_stat_pre = CAR_pre/SD_CAR_prepost
			scalar p_value_pre = ttail(df ,abs(t_stat_pre))*2
			di CAR_pre
			di p_value_pre

		* Event day
			scalar t_stat_event = CAR_event/SD_CAR_event
			scalar p_value_event = ttail(df ,abs(t_stat_event))*2
			di CAR_event
			di p_value_event

		* Post-event
			scalar t_stat_post = CAR_post/SD_CAR_prepost
			scalar p_value_post = ttail(df ,abs(t_stat_post))*2
			di CAR_post
			di p_value_post
			
		* Full Event window
			scalar t_stat_event_win = CAR_event_win/SD_CAR_event_win
			scalar p_value_event_win = ttail(df ,abs(t_stat_event_win))*2
			di CAR_event_win
			di p_value_event_win











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

