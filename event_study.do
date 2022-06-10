	
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
