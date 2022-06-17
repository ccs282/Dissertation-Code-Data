
// CHANGE TO MAKE COUNTRY_NAME COME FIRST

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
			capture drop ew
			gen ew = .
			summ trading_date if event_date == 1
			replace ew = 1 if (trading_date >= r(mean) - event_length_pre) & (trading_date <= r(mean) + event_length_post)
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop ew_`x'_`i'
						gen ew_`x'_`i' = .
						summ trading_date if event_date_`x'_`i' == 1
						replace ew_`x'_`i' = 1 if (trading_date >= r(mean) - event_length_pre) & (trading_date <= r(mean) + event_length_post)
					}
				}
			}	
		}

	** Estimation win
			
		if test_specific_date == "yes" {
			capture drop est_win
			gen est_win = .
			summ trading_date if event_date == 1
			replace est_win = 1 if (trading_date >= r(mean) - event_length_pre - est_length) & (trading_date < r(mean) - event_length_pre)
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop est_win_`x'_`i'
						gen est_win_`x'_`i' = .
						summ trading_date if event_date_`x'_`i' == 1
						replace est_win_`x'_`i' = 1 if (trading_date >= r(mean) - event_length_pre - est_length) & (trading_date < r(mean) - event_length_pre)
					}
				}
			}	

		}

	** Normal returns
		if test_specific_date == "yes" {
			capture drop NR

			if reg_type == 1 {
				summ ln_return_eua if est_win == 1 & date >= earliest_date
				gen NR = r(mean)
				scalar df = est_length - 10 // what exactly?
			}

			else if reg_type == 2 {
				reg ln_return_eua L.ln_return_eua $ln_return_explanatory if est_win == 1 & date >= earliest_date, robust
				predict NR
				scalar df = e(df_m)
			}

			else if reg_type == 3 {
				reg eua L.eua $explanatory if est_win == 1 & date >= earliest_date, robust
				predict NR
				scalar df = e(df_m)

			}
			
			order NR, after(ln_return_eua) 
		}

		else{
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop NR_`x'_`i'

						if reg_type == 1 {
							summ ln_return_eua if est_win_`x'_`i' == 1
							gen NR_`x'_`i' = r(mean)
							scalar df = est_length - 10 // what exactly?

						}

						else if reg_type == 2 {
							reg ln_return_eua L.ln_return_eua $ln_return_explanatory if est_win_`x'_`i' == 1 & date >= earliest_date, robust
							predict NR_`x'_`i'
							scalar df = e(df_m)

						}

						else if reg_type == 3 {
							reg eua L.eua $explanatory if est_win_`x'_`i' == 1 & date >= earliest_date, robust
							predict NR_`x'_`i'
							scalar df = e(df_m)

						}
					}
				}
			}	
		}

	** Abnormal returns
		if test_specific_date == "yes" {
			capture drop AR
			gen AR = ln_return_eua - NR
			order AR, after(NR)
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
						capture drop AR_`x'_`i'
						if reg_type == 3 {
							gen AR_`x'_`i' = eua - NR_`x'_`i'
						}
						else {
							gen AR_`x'_`i' = ln_return_eua - NR_`x'_`i'

						}
					}
				}
			}	
		}

		/*
		if reg_type == 3 {
			gen AR = eua - NR 
			
			capture drop AR_perc
			gen AR_perc = AR/NR
			order AR_perc, after(NR)
		}
		*/

	** Cumulative abnormal returns

		if test_specific_date == "yes" {
			capture drop CAR*
			//tempname CAR_ew CAR_pre CAR_post CAR_event
			
			* Event window
				egen CARa = total(AR) if ew == 1
				summ CARa, meanonly
				scalar CAR_ew = r(mean)
				
			* Pre-event
				egen CARb = total(AR) if ew == 1 & date < date_specific
				summ CARb, meanonly
				scalar CAR_pre = r(mean)

			* Post-event
				egen CARc = total(AR) if ew == 1 & date > date_specific
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
							egen CARa = total(AR_`x'_`i') if ew_`x'_`i' == 1
							summ CARa, meanonly
							scalar CAR_ew_`x'_`i' = r(mean)
	
						* Pre-event
							summ date if event_date_`x'_`i' == 1, meanonly
							egen CARb = total(AR_`x'_`i') if ew_`x'_`i' == 1 & date < `r(mean)'
							summ CARb, meanonly
							scalar CAR_pre_`x'_`i' = r(mean)

						* Post-event
							summ date if event_date_`x'_`i' == 1, meanonly
							egen CARc = total(AR_`x'_`i') if ew_`x'_`i' == 1 & date > `r(mean)'
							summ CARc, meanonly
							scalar CAR_post_`x'_`i' = r(mean)

						* Event Day
							egen CARd = total(AR_`x'_`i') if event_date_`x'_`i' == 1
							summ CARd, meanonly
							scalar CAR_event_`x'_`i' = r(mean)

						capture drop CAR*

						* Every single day within the event window
							tab date if ew_`x'_`i' == 1, matrow(mat_`x'_`i')

							local pre = event_length_pre
							local post = event_length_post

							forvalues t = -`pre'(1)`post' {
								capture drop CAR*
								local nom = `t' + event_length_pre + 1
								egen CAR_temp = total(AR_`x'_`i') if date == mat_`x'_`i'[`nom', 1]
								summ CAR_temp, meanonly
								scalar CAR_d`nom'_`x'_`i' = `r(mean)'
							}

							capture drop CAR*
					}
				}
			}
		}


	** Average CAR across dates and countries

		if test_specific_date != "yes" {
			scalar No = Germany_num + UK_num + Spain_num + Italy_num + Czech_Republic_num + Netherlands_num + France_num + Romania_num + Bulgaria_num + Greece_num + Others_num

            * Pre-event
                foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                    	local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            capture drop v_CAR_pre_`x'_`i'
                            gen v_CAR_pre_`x'_`i' = CAR_pre_`x'_`i'
                        }
                    }
			    }

                egen v_CAR_pre_avg = rowmean(v_CAR*)
                scalar CAR_pre_avg = v_CAR_pre_avg[1]
                capture drop v_*
                    
			* Post-event
                foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                         local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            capture drop v_CAR_post_`x'_`i'
                            gen v_CAR_post_`x'_`i' = CAR_post_`x'_`i'
                        }
                    }
			    }

                egen v_CAR_post_avg = rowmean(v_CAR*)
                scalar CAR_post_avg = v_CAR_post_avg[1]
                capture drop v_*
                    
			* Event Day
				foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                        local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            capture drop v_CAR_event_`x'_`i'
                            gen v_CAR_event_`x'_`i' = CAR_event_`x'_`i'
                        }
                    }
			    }

                egen v_CAR_event_avg = rowmean(v_CAR*)
                scalar CAR_event_avg = v_CAR_event_avg[1]
                capture drop v_*

            * Event window
				foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                        local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            capture drop v_CAR_ew_`x'_`i'
                            gen v_CAR_ew_`x'_`i' = CAR_ew_`x'_`i'
                        }
                    }
			    }

                egen v_CAR_ew_avg = rowmean(v_CAR*)
                scalar CAR_ew_avg = v_CAR_ew_avg[1]
                capture drop v_*
		}


