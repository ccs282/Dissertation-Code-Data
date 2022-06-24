	
    ** Variance & SD AR (estimation win)
		if test_specific_date == "yes" {
        	summ ln_return_eua if est_win == 1
            capture drop AR_squared
            capture drop TSS
            gen AR_squared = .
            replace AR_squared = AR^2 if est_win == 1
            egen TSS = total(AR_squared) if est_win == 1
            summ TSS
            scalar TSS_aux = r(mean)
            summ trading_date if est_win == 1
            // - 2 is only if two parameters need to be estimated?!
            // formula wrong?! what is subtracted (number of variables used in calculation) and r(max)-r(min) doesnt consider missing values
            scalar var_AR = (1/(r(max)-r(min)-2))*TSS_aux
            scalar SD_AR = sqrt(var_AR)
            capture drop AR_squared TSS 
		}

		else {
			foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
                    	summ ln_return_eua if est_win_`x'_`i' == 1
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
                scalar var_CAR_ew = (event_length_pre + event_length_post+1)*var_AR
                scalar SD_CAR_ew = sqrt(var_CAR_ew)

            * Pre-event
                scalar var_CAR_pre = event_length_pre*var_AR
                scalar SD_CAR_pre = sqrt(var_CAR_pre)

            * Post-event
                scalar var_CAR_post = event_length_post*var_AR
                scalar SD_CAR_post = sqrt(var_CAR_post)

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
                            scalar var_CAR_ew_`x'_`i' = (event_length_pre + event_length_post+1)*var_AR_`x'_`i'
                            scalar SD_CAR_ew_`x'_`i' = sqrt(var_CAR_ew_`x'_`i')

                        * Pre-event
                            scalar var_CAR_pre_`x'_`i' = event_length_pre*var_AR_`x'_`i'
                            scalar SD_CAR_pre_`x'_`i' = sqrt(var_CAR_pre_`x'_`i')

                        * Post-event 
                            scalar var_CAR_post_`x'_`i' = event_length_post*var_AR_`x'_`i'
                            scalar SD_CAR_post_`x'_`i' = sqrt(var_CAR_post_`x'_`i')

                        * Event Day
                            scalar var_CAR_event_`x'_`i' = var_AR_`x'_`i'
                            scalar SD_CAR_event_`x'_`i' = sqrt(var_CAR_event_`x'_`i')
					}
				}
			}
        }

    ** Variance & SD average CAR (event window; across different dates)
		
		if test_specific_date != "yes" {
            * Pre-event
                foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                    	local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            gen v_var_CAR_pre_`x'_`i' = var_CAR_pre_`x'_`i'
                        }
                    }
			    }

                egen v_var_CAR_pre_sum = rowtotal(v_*)
                scalar var_CAR_pre_avg = v_var_CAR_pre_sum[1]/No^2
                scalar SD_CAR_pre_avg = sqrt(var_CAR_pre_avg)

                capture drop v_*

			* Post-event
                foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
                    if `x'_num != 0 {
                    	local temp = `x'_num
                        forvalues i = 1(1)`temp' {
                            gen v_var_CAR_post_`x'_`i' = var_CAR_post_`x'_`i'
                        }
                    }
			    }

                egen v_var_CAR_post_sum = rowtotal(v_*)
                scalar var_CAR_post_avg = v_var_CAR_post_sum[1]/No^2
                scalar SD_CAR_post_avg = sqrt(var_CAR_post_avg)

                capture drop v_*


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
                scalar var_CAR_event_avg = v_var_CAR_event_sum[1]/No^2
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
                scalar var_CAR_ew_avg = v_var_CAR_ew_sum[1]/No^2
                scalar SD_CAR_ew_avg = sqrt(var_CAR_ew_avg)

                capture drop v_*
		}


    ** Significance
            ** Test statistical significance
		// scalar df = 950 // use df from reg output? what to do for const mean method
		/*scalar level = 0.05
		scalar cv = invttail(df, level/2)*/
		
        if test_specific_date == "yes" {
            * Pre-event
                scalar t_pre = CAR_pre/SD_CAR_pre
                scalar p_pre = ttail(df ,abs(t_pre))*2

            * Event day
                scalar t_event = CAR_event/SD_CAR_event
                scalar p_event = ttail(df ,abs(t_event))*2

            * Post-event
                scalar t_post = CAR_post/SD_CAR_post
                scalar p_post = ttail(df ,abs(t_post))*2
                
            * Full Event window
                scalar t_ew = CAR_ew/SD_CAR_ew
                scalar p_ew = ttail(df ,abs(t_ew))*2

            * Individual days within event window

				local pre = event_length_pre
				local post = event_length_post

                forvalues t = -`pre'(1)`post' {
                    local nom = `t' + event_length_pre + 1
                    scalar t_d`nom' = CAR_d`nom'/SD_CAR_event
                    scalar p_d`nom' = ttail(df ,abs(t_d`nom'))*2
				}



		}

        else {
            foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
                        * Pre-event
                            scalar t_pre_`x'_`i' = CAR_pre_`x'_`i'/SD_CAR_pre_`x'_`i'
                            scalar p_pre_`x'_`i' = ttail(df_`x'_`i' ,abs(t_pre_`x'_`i'))*2

                        * Event day
                            scalar t_event_`x'_`i' = CAR_event_`x'_`i'/SD_CAR_event_`x'_`i'
                            scalar p_event_`x'_`i' = ttail(df_`x'_`i' ,abs(t_event_`x'_`i'))*2

                        * Post-event
                            scalar t_post_`x'_`i' = CAR_post_`x'_`i'/SD_CAR_post_`x'_`i'
                            scalar p_post_`x'_`i' = ttail(df_`x'_`i' ,abs(t_post_`x'_`i'))*2
                            
                        * Full Event window
                            scalar t_ew_`x'_`i' = CAR_ew_`x'_`i'/SD_CAR_ew_`x'_`i'
                            scalar p_ew_`x'_`i' = ttail(df_`x'_`i' ,abs(t_ew_`x'_`i'))*2
                        
                        * Individual days within event window

							local pre = event_length_pre
							local post = event_length_post

                            forvalues t = -`pre'(1)`post' {
                                local nom = `t' + event_length_pre + 1
                                scalar t_d`nom'_`x'_`i' = CAR_d`nom'_`x'_`i'/SD_CAR_event_`x'_`i'
                                scalar p_d`nom'_`x'_`i' = ttail(df_`x'_`i' ,abs(t_d`nom'_`x'_`i'))*2
				            }
                    }
				}
			}

            * Average CAR

                // temp, adapt later
                scalar df = est_length - 15
                * Pre-event
                    scalar t_pre_avg = CAR_pre_avg/SD_CAR_pre_avg
                    scalar p_pre_avg = ttail(df ,abs(t_pre_avg))*2

                * Event day
                    scalar t_event_avg = CAR_event_avg/SD_CAR_event_avg
                    scalar p_event_avg = ttail(df ,abs(t_event_avg))*2

                * Post-event
                    scalar t_post_avg = CAR_post_avg/SD_CAR_post_avg
                    scalar p_post_avg = ttail(df ,abs(t_post_avg))*2
                            
                * Full Event window
                    scalar t_ew_avg = CAR_ew_avg/SD_CAR_ew_avg
                    scalar p_ew_avg = ttail(df ,abs(t_ew_avg))*2

                * Individual days within event window
                    forvalues t = -`pre'(1)`post' {
                        local nom = `t' + event_length_pre + 1
                        scalar t_d`nom'_avg = CAR_d`nom'_avg/SD_CAR_event_avg
                        scalar p_d`nom'_avg = ttail(df ,abs(t_d`nom'_avg))*2
				    }
        }
