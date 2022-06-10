	
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
