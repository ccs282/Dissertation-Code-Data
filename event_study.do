
    ** Event time

		if test_specific_date == "yes" {
			capture drop event_date
			gen event_date = .
			replace event_date = 1 if date == date_specific 
		}

		else {
			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_d
						if _rc == 0 {
							capture drop event_date_`x'_`y'`i'
							gen event_date_`x'_`y'`i' = .
							replace event_date_`x'_`y'`i' = 1 if date == `x'_`y'`i'_d
						}
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

			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_d
						if _rc == 0 {
							capture drop ew_`x'_`y'`i'
							gen ew_`x'_`y'`i' = .
							summ trading_date if event_date_`x'_`y'`i' == 1
							replace ew_`x'_`y'`i' = 1 if (trading_date >= r(mean) - event_length_pre) & (trading_date <= r(mean) + event_length_post)
						}
					}
				}
			}
		}

	** Estimation win
			
		if test_specific_date == "yes" {
			capture drop est_win
			gen est_win = .
			summ trading_date if event_date == 1
			replace est_win = 1 if (trading_date >= r(mean) - event_length_pre - est_length) & (trading_date < r(mean) - event_length_pre) & (date >= earliest_date)
		}

		else {
			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_d
						if _rc == 0 {
							capture drop est_win_`x'_`y'`i'
							gen est_win_`x'_`y'`i' = .
							summ trading_date if event_date_`x'_`y'`i' == 1
							replace est_win_`x'_`y'`i' = 1 if (trading_date >= r(mean) - event_length_pre - est_length) & (trading_date < r(mean) - event_length_pre) & (date >= earliest_date)
						}
					}
				}
			}
		}

	** Normal returns
		if test_specific_date == "yes" {
			capture drop NR

		* Constant mean
			if reg_type == 1 {
				reg ln_return_eua est_win if est_win == 1, robust noconst
				gen NR = e(b)[1, 1]
				scalar df = e(df_r)
			}

		* Zero mean
			else if reg_type == 2 {
				gen NR = 0
				reg ln_return_eua est_win if est_win == 1, robust noconst
				scalar df = e(df_r)
			}

		* Koch et al. (2016) variables model
			else if reg_type == 3 {
				reg ln_return_eua L.ln_return_eua $ln_return_explanatory if est_win == 1, robust
				scalar df = e(df_r)

				predict NR if est_win == 1

				summ trading_date if event_date == 1
				capture drop tempv 
				gen tempv = ln_return_eua if trading_date < (r(mean) - event_length_pre) // create a temporary variable for the recursive estimation (bc. of the lagged dependent variable)

				reg tempv L.tempv $ln_return_explanatory if est_win == 1, robust
	
				local ew_length = event_length_post + event_length_pre + 1
				forvalues i = 1(1)`ew_length' {
					summ trading_date if event_date == 1
					predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
					replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
					replace NR = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
				}

				drop NR_* tempv
			}

			order NR, after(ln_return_eua) 
		}

		else{

			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_d
						if _rc == 0 {
							capture drop NR_`x'_`y'`i'

							* Constant Mean
							if reg_type == 1 {
								reg ln_return_eua est_win_`x'_`y'`i' if est_win_`x'_`y'`i' == 1, robust noconst
								gen NR_`x'_`y'`i' = e(b)[1, 1]
								scalar df_`x'_`y'`i' = e(df_r)
							}

							* Zero Mean
							else if reg_type == 2 {
								gen NR_`x'_`y'`i' = 0
								reg ln_return_eua est_win_`x'_`y'`i' if est_win_`x'_`y'`i' == 1, robust noconst
								scalar df_`x'_`y'`i' = e(df_r)
							}

							* Koch et al. (2016) variables model
							else if reg_type == 3 {
								// determine lag length using AIC/BIC!!!
								reg ln_return_eua L.ln_return_eua $ln_return_explanatory if est_win_`x'_`y'`i' == 1, robust
								scalar df_`x'_`y'`i' = e(df_r)

								predict NR_`x'_`y'`i' if est_win_`x'_`y'`i' == 1

								summ trading_date if event_date_`x'_`y'`i' == 1
								capture drop tempv = . 
								gen tempv = ln_return_eua if trading_date < (r(mean) - event_length_pre) // create a temporary variable for the recursive estimation (bc. of the lagged dependent variable)

								reg tempv L.tempv $ln_return_explanatory if est_win_`x'_`y'`i' == 1, robust
					
								local ew_length = event_length_post + event_length_pre + 1
								forvalues j = 1(1)`ew_length' {
									summ trading_date if event_date_`x'_`y'`i' == 1
									predict NR_`x'_`y'`i'_`j' if trading_date == (r(mean) - event_length_pre -1 + `j')
									replace tempv = NR_`x'_`y'`i'_`j' if trading_date == (r(mean) - event_length_pre -1 + `j')
									replace NR_`x'_`y'`i' = NR_`x'_`y'`i'_`j' if trading_date == (r(mean) - event_length_pre -1 + `j')
								}

								drop NR_`x'_`y'`i'_* tempv
							}
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
			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_d
						if _rc == 0 {
							capture drop AR_`x'_`y'`i'
							gen AR_`x'_`y'`i' = ln_return_eua - NR_`x'_`y'`i'
						}
					}
				}
			}
		}

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

			* Every single day within the event window
				tab date if ew == 1, matrow(matrix_)

				global pre = event_length_pre
				global post = event_length_post

				forvalues t = -$pre(1)$post {
					capture drop CAR*
					local nom = `t' + event_length_pre + 1
					egen CAR_temp = total(AR) if date == matrix_[`nom', 1]
					summ CAR_temp, meanonly
					scalar CAR_d`nom' = `r(mean)'
				}

				capture drop CAR*

		}

		else {

			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_d
						if _rc == 0 {
							* Event window
								egen CARa = total(AR_`x'_`y'`i') if ew_`x'_`y'`i' == 1
								summ CARa, meanonly
								scalar CAR_ew_`x'_`y'`i' = r(mean)
		
							* Pre-event
								summ date if event_date_`x'_`y'`i' == 1, meanonly
								egen CARb = total(AR_`x'_`y'`i') if ew_`x'_`y'`i' == 1 & date < `r(mean)'
								summ CARb, meanonly
								scalar CAR_pre_`x'_`y'`i' = r(mean)

							* Post-event
								summ date if event_date_`x'_`y'`i' == 1, meanonly
								egen CARc = total(AR_`x'_`y'`i') if ew_`x'_`y'`i' == 1 & date > `r(mean)'
								summ CARc, meanonly
								scalar CAR_post_`x'_`y'`i' = r(mean)

							* Event Day
								egen CARd = total(AR_`x'_`y'`i') if event_date_`x'_`y'`i' == 1
								summ CARd, meanonly
								scalar CAR_event_`x'_`y'`i' = r(mean)

							capture drop CAR*

							* Every single day within the event window
								tab date if ew_`x'_`y'`i' == 1, matrow(mat_`x'_`y'`i')

								global pre = event_length_pre
								global post = event_length_post

								// let it run from 1 to ew_length instead? same outcome, easier though
								forvalues t = -$pre(1)$post {
									capture drop CAR*
									local nom = `t' + event_length_pre + 1
									egen CAR_temp = total(AR_`x'_`y'`i') if date == mat_`x'_`y'`i'[`nom', 1]
									summ CAR_temp, meanonly
									scalar CAR_d`nom'_`x'_`y'`i' = `r(mean)'
								}

								capture drop CAR*
						}
					}
				}
			}



			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_d
						if _rc == 0 {
							* Event window
								egen CARa = total(AR_`x'_`y'`i') if ew_`x'_`y'`i' == 1
								summ CARa, meanonly
								scalar CAR_ew_`x'_`y'`i' = r(mean)
		
							* Pre-event
								summ date if event_date_`x'_`y'`i' == 1, meanonly
								egen CARb = total(AR_`x'_`y'`i') if ew_`x'_`y'`i' == 1 & date < `r(mean)'
								summ CARb, meanonly
								scalar CAR_pre_`x'_`y'`i' = r(mean)

							* Post-event
								summ date if event_date_`x'_`y'`i' == 1, meanonly
								egen CARc = total(AR_`x'_`y'`i') if ew_`x'_`y'`i' == 1 & date > `r(mean)'
								summ CARc, meanonly
								scalar CAR_post_`x'_`y'`i' = r(mean)

							* Event Day
								egen CARd = total(AR_`x'_`y'`i') if event_date_`x'_`y'`i' == 1
								summ CARd, meanonly
								scalar CAR_event_`x'_`y'`i' = r(mean)

							capture drop CAR*

							* Every single day within the event window
								tab date if ew_`x'_`y'`i' == 1, matrow(mat_`x'_`y'`i')

								global pre = event_length_pre
								global post = event_length_post

								// let it run from 1 to ew_length instead? same outcome, easier though
								forvalues t = -$pre(1)$post {
									capture drop CAR*
									local nom = `t' + event_length_pre + 1
									egen CAR_temp = total(AR_`x'_`y'`i') if date == mat_`x'_`y'`i'[`nom', 1]
									summ CAR_temp, meanonly
									scalar CAR_d`nom'_`x'_`y'`i' = `r(mean)'
								}

								capture drop CAR*
						}
					}
				}
			}
		}


	** Average CAR across dates and countries

		if test_specific_date != "yes" {

			scalar No = 0
			
			foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
				foreach y in main alt new rev follow leak canc parl nuc {
					forvalues i = 1(1)10 {
						capture confirm scalar `x'_`y'`i'_s
						if _rc == 0 {
							if `x'_`y'`i'_s == 1 {
								scalar No = No + `x'_`y'`i'_s
							}
						}
					}
				}
			}

            * Pre-event
				foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
					foreach y in main alt new rev follow leak canc parl nuc {
						forvalues i = 1(1)10 {
							capture confirm scalar `x'_`y'`i'_d
							if _rc == 0 {
								capture drop v_CAR_pre_`x'_`y'`i'
                            	gen v_CAR_pre_`x'_`y'`i' = CAR_pre_`x'_`y'`i'
							}
						}
					}
				}

                egen v_CAR_pre_avg = rowmean(v_CAR*)
                scalar CAR_pre_avg = v_CAR_pre_avg[1]
                capture drop v_*
                    
			* Post-event

				foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
					foreach y in main alt new rev follow leak canc parl nuc {
						forvalues i = 1(1)10 {
							capture confirm scalar `x'_`y'`i'_d
							if _rc == 0 {
								capture drop v_CAR_post_`x'_`y'`i'
								gen v_CAR_post_`x'_`y'`i' = CAR_post_`x'_`y'`i'
							}
						}
					}
				}

                egen v_CAR_post_avg = rowmean(v_CAR*)
                scalar CAR_post_avg = v_CAR_post_avg[1]
                capture drop v_*
                    
			* Event Day

				foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
					foreach y in main alt new rev follow leak canc parl nuc {
						forvalues i = 1(1)10 {
							capture confirm scalar `x'_`y'`i'_d
							if _rc == 0 {
								capture drop v_CAR_event_`x'_`y'`i'
                            	gen v_CAR_event_`x'_`y'`i' = CAR_event_`x'_`y'`i'
							}
						}
					}
				}

                egen v_CAR_event_avg = rowmean(v_CAR*)
                scalar CAR_event_avg = v_CAR_event_avg[1]
                capture drop v_*

            * Event window

				foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
					foreach y in main alt new rev follow leak canc parl nuc {
						forvalues i = 1(1)10 {
							capture confirm scalar `x'_`y'`i'_d
							if _rc == 0 {
								capture drop v_CAR_ew_`x'_`y'`i'
								gen v_CAR_ew_`x'_`y'`i' = CAR_ew_`x'_`y'`i'
							}
						}
					}
				}

                egen v_CAR_ew_avg = rowmean(v_CAR*)
                scalar CAR_ew_avg = v_CAR_ew_avg[1]
                capture drop v_*

			* Every single day within the event window

				foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
					foreach y in main alt new rev follow leak canc parl nuc {
						forvalues i = 1(1)10 {
							capture confirm scalar `x'_`y'`i'_d
							if _rc == 0 {
								forvalues t = -$pre(1)$post {
									local nom = `t' + event_length_pre + 1
									capture drop v_CAR_d`nom'_`x'_`y'`i'
									gen v_CAR_d`nom'_`x'_`y'`i' = CAR_d`nom'_`x'_`y'`i'
								}
							}
						}
					}
				}

				forvalues t = -$pre(1)$post {
					local nom = `t' + event_length_pre + 1
					egen v_CAR_d`nom'_avg = rowmean(v_CAR_d`nom'*)
                	scalar CAR_d`nom'_avg = v_CAR_d`nom'_avg[1]
				}
				
				capture drop v_*
		}


