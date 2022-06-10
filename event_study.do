	
    ** Event time

		if test_specific_date == "yes" {
			capture drop event_date
			gen event_date = .
			replace event_date = 1 if date == date_specific 
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop event_date_`x'_`i'
						gen event_date_`x'_`i' = .
						replace event_date_`x'_`i' = 1 if date == announce_date[`x'_row, `i']
					}
				}
			}	
		}

	** Event window

		if test_specific_date == "yes" {
			capture drop event_win
			gen event_win = .
			summ trading_date if event_date == 1
			replace event_win = 1 if (trading_date >= r(mean) - event_length) & (trading_date <= r(mean) + event_length)
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop event_win_`x'_`i'
						gen event_win_`x'_`i' = .
						summ trading_date if event_date_`x'_`i' == 1
						replace event_win_`x'_`i' = 1 if (trading_date >= r(mean) - event_length) & (trading_date <= r(mean) + event_length)
					}
				}
			}	
		}

	** Estimation win
			
		if test_specific_date == "yes" {
			capture drop est_win
			gen est_win = .
			summ trading_date if event_date == 1
			replace est_win = 1 if (trading_date >= r(mean) - event_length - est_length) & (trading_date < r(mean) - event_length)
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop est_win_`x'_`i'
						gen est_win_`x'_`i' = .
						summ trading_date if event_date_`x'_`i' == 1
						replace est_win_`x'_`i' = 1 if (trading_date >= r(mean) - event_length - est_length) & (trading_date < r(mean) - event_length)
					}
				}
			}	

		}

	** Normal returns
		if test_specific_date == "yes" {
			capture drop NR

			if reg_type == 1 {
				summ ln_return_eua_settle if est_win == 1
				gen NR = r(mean)
			}

			else if reg_type == 2 {
				reg ln_return_eua_settle L.ln_return_eua_settle $ln_return_explanatory if est_win == 1 & date >= earliest_date, robust
				predict NR
			}

			else if reg_type == 3 {
				reg eua_settle L.eua_settle $explanatory if est_win == 1 & date >= earliest_date, robust
				predict NR
			}
			
			order NR, after(ln_return_eua_settle) 
		}

		else{
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop NR_`x'_`i'

						if reg_type == 1 {
							summ ln_return_eua_settle if est_win_`x'_`i' == 1
							gen NR_`x'_`i' = r(mean)
						}

						else if reg_type == 2 {
							reg ln_return_eua_settle L.ln_return_eua_settle $ln_return_explanatory if est_win_`x'_`i' == 1 & date >= earliest_date, robust
							predict NR_`x'_`i'
						}

						else if reg_type == 3 {
							reg eua_settle L.eua_settle $explanatory if est_win_`x'_`i' == 1 & date >= earliest_date, robust
							predict NR_`x'_`i'
						}
					}
				}
			}	
		}

	** Abnormal returns
		if test_specific_date == "yes" {
			capture drop AR
			gen AR = ln_return_eua_settle - NR
			order AR, after(NR)
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop AR_`x'_`i'
						gen AR_`x'_`i' = ln_return_eua_settle - NR_`x'_`i'
					}
				}
			}	
		}

		/*
		if reg_type == 3 {
			gen AR = eua_settle - NR 
			
			capture drop AR_perc
			gen AR_perc = AR/NR
			order AR_perc, after(NR)
		}
		*/

	** Cumulative abnormal returns

		if test_specific_date == "yes" {
			capture drop CAR*
			//tempname CAR_event_win CAR_pre CAR_post CAR_event
			
			* Event window
				egen CARa = total(AR) if event_win == 1
				summ CARa, meanonly
				scalar CAR_event_win = r(mean)
				
			* Pre-event
				egen CARb = total(AR) if event_win == 1 & date < date_specific
				summ CARb, meanonly
				scalar CAR_pre = r(mean)

			* Post-event
				egen CARc = total(AR) if event_win == 1 & date > date_specific
				summ CARc, meanonly
				scalar CAR_post = r(mean)

			* Event Day
				egen CARd = total(AR) if event_date == 1
				summ CARd, meanonly
				scalar CAR_event = r(mean)
			
			capture drop CAR*
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						* Event window
							egen CARa = total(AR_`x'_`i') if event_win_`x'_`i' == 1
							summ CARa, meanonly
							scalar CAR_event_win_`x'_`i' = r(mean)
							
						* Pre-event
							egen CARb = total(AR_`x'_`i') if event_win_`x'_`i' == 1 & date < event_date_`x'_`i'
							summ CARb, meanonly
							scalar CAR_pre_`x'_`i' = r(mean)

//// POST WRONG????????

						* Post-event
							egen CARc = total(AR_`x'_`i') if event_win_`x'_`i' == 1 & date > event_date_`x'_`i'
							summ CARc, meanonly
							scalar CAR_post_`x'_`i' = r(mean)

						* Event Day
							egen CARd = total(AR_`x'_`i') if event_date_`x'_`i' == 1
							summ CARd, meanonly
							scalar CAR_event_`x'_`i' = r(mean)
						
						capture drop CAR*
					}
				}
			}

// EVENT DAY AND POST IDENTICAL?????????????????????

            * Average CAR across dates and countries
                scalar N = Germany_num + UK_num + Spain_num + Italy_num + Czech_Republic_num + Netherlands_num + France_num + Romania_num + Bulgaria_num + Greece_num + Others_num

                * Pre-event
                    foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                        if `x'_num != 0 {
                            local temp = `x'_num
                            forvalues i = 1(1)`temp' {
                                capture drop var_CAR_pre_`x'_`i'
                                gen var_CAR_pre_`x'_`i' = CAR_pre_`x'_`i'
                            }
                        }
			        }

                    egen var_CAR_pre_avg = rowmean(var_CAR*)
                    scalar CAR_pre_avg = var_CAR_pre_avg[1]
                    capture drop var_*
                    
			    * Post-event
                    foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                        if `x'_num != 0 {
                            local temp = `x'_num
                            forvalues i = 1(1)`temp' {
                                capture drop var_CAR_post_`x'_`i'
                                gen var_CAR_post_`x'_`i' = CAR_post_`x'_`i'
                            }
                        }
			        }

                    egen var_CAR_post_avg = rowmean(var_CAR*)
                    scalar CAR_post_avg = var_CAR_post_avg[1]
                    capture drop var_*
                    

				* Event Day
                * Event window

		}
