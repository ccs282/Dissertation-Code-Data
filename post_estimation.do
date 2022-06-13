	
    ** Variance & SD AR (estimation win)
		if test_specific_date == "yes" {
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
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
                    	summ ln_return_eua_settle if est_win_`x'_`i' == 1
                        capture drop AR_squared
                        capture drop TSS
                        gen AR_squared = .
                        replace AR_squared = AR_`x'_`i'^2 if est_win_`x'_`i' == 1
                        egen TSS = total(AR_squared) if est_win_`x'_`i' == 1
                        summ TSS
                        scalar TSS_aux = r(mean)
                        summ trading_date if est_win_`x'_`i' == 1
                        scalar var_AR_`x'_`i' = (1/(r(max)-r(min)-2))*TSS_aux
                        scalar SD_AR_`x'_`i' = sqrt(var_AR_`x'_`i')
                        capture drop AR_squared TSS
                        scalar drop TSS_aux 
					}
				}
			}
        }

	** Variance & SD CAR (event window)
		if test_specific_date == "yes" {
            * Full Event window
                scalar var_CAR_event_win = (2*event_length+1)*var_AR
                scalar SD_CAR_event_win = sqrt(var_CAR_event_win)

            * Pre-event & Post-event
                scalar var_CAR_prepost = event_length*var_AR
                scalar SD_CAR_prepost = sqrt(var_CAR_prepost)

            * Event Day
                scalar var_CAR_event = var_AR
                scalar SD_CAR_event = sqrt(var_CAR_event)
		}

        else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
                        * Full Event window
                            scalar var_CAR_ew_`x'_`i' = (2*event_length+1)*var_AR_`x'_`i'
                            scalar SD_CAR_ew_`x'_`i' = sqrt(var_CAR_ew_`x'_`i')

                        * Pre-event
                            scalar var_CAR_pre_`x'_`i' = event_length*var_AR_`x'_`i'
                            scalar SD_CAR_pre_`x'_`i' = sqrt(var_CAR_pre_`x'_`i')

                        * Post-event 
                            scalar var_CAR_post_`x'_`i' = var_CAR_pre_`x'_`i'
                            scalar SD_CAR_post_`x'_`i' = SD_CAR_pre_`x'_`i'

                        * Event Day
                            scalar var_CAR_event_`x'_`i' = var_AR_`x'_`i'
                            scalar SD_CAR_event_`x'_`i' = sqrt(var_CAR_event_`x'_`i')

					}
				}
			}
        }

    ** Variance & SD avg CAR (event window; across different dates)
		
		if test_specific_date != "yes" {
            * Pre-event
                foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                    	local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            capture drop v_*
                            gen v_var_CAR_pre_`x'_`i' = var_CAR_pre_`x'_`i'
                        }
                    }
			    }

                egen v_var_CAR_pre_sum = rowtotal(v_*)
                scalar var_CAR_pre_avg = v_var_CAR_pre_sum[1]/N^2
                scalar SD_CAR_pre_avg = sqrt(var_CAR_pre_avg)

                capture drop v_*

			* Post-event
                scalar var_CAR_post_avg = var_CAR_pre_avg
                scalar SD_CAR_post_avg = SD_CAR_pre_avg

			* Event Day
                foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                    	local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            gen v_var_CAR_event_`x'_`i' = var_CAR_event_`x'_`i'
                        }
                    }
			    }

                egen v_var_CAR_event_sum = rowtotal(v_*)
                scalar var_CAR_event_avg = v_var_CAR_event_sum[1]/N^2
                scalar SD_CAR_event_avg = sqrt(var_CAR_event_avg)

                capture drop v_*

            * Event window
                foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                    	local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            gen v_var_CAR_ew_`x'_`i' = var_CAR_ew_`x'_`i'
                        }
                    }
			    }

                egen v_var_CAR_ew_sum = rowtotal(v_*)
                scalar var_CAR_ew_avg = v_var_CAR_ew_sum[1]/N^2
                scalar SD_CAR_ew_avg = sqrt(var_CAR_ew_avg)

                capture drop v_*
		}





