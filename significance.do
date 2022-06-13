	
    ** Test statistical significance
		// scalar df = 950 // use df from reg output? what to do for const mean method
		/*scalar level = 0.05
		scalar cv = invttail(df, level/2)*/
		
        if test_specific_date == "yes" {
            * Pre-event
                scalar t_pre = CAR_pre/SD_CAR_pre
                scalar p_pre = ttail(df ,abs(t_pre))*2
                di CAR_pre
                di p_pre

            * Event day
                scalar t_event = CAR_event/SD_CAR_event
                scalar p_event = ttail(df ,abs(t_event))*2
                di CAR_event
                di p_event

            * Post-event
                scalar t_post = CAR_post/SD_CAR_post
                scalar p_post = ttail(df ,abs(t_post))*2
                di CAR_post
                di p_post
                
            * Full Event window
                scalar t_ew = CAR_ew/SD_CAR_ew
                scalar p_ew = ttail(df ,abs(t_ew))*2
                di CAR_ew
                di p_ew
		}

        else {
            foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
                        * Pre-event
                            scalar t_pre_`x'_`i' = CAR_pre_`x'_`i'/SD_CAR_pre_`x'_`i'
                            scalar p_pre_`x'_`i' = ttail(df ,abs(t_pre_`x'_`i'))*2

                        * Event day
                            scalar t_event_`x'_`i' = CAR_event_`x'_`i'/SD_CAR_event_`x'_`i'
                            scalar p_event_`x'_`i' = ttail(df ,abs(t_event_`x'_`i'))*2

                        * Post-event
                            scalar t_post_`x'_`i' = CAR_post_`x'_`i'/SD_CAR_post_`x'_`i'
                            scalar p_post_`x'_`i' = ttail(df ,abs(t_post_`x'_`i'))*2
                            
                        * Full Event window
                            scalar t_ew_`x'_`i' = CAR_ew_`x'_`i'/SD_CAR_ew_`x'_`i'
                            scalar p_ew_`x'_`i' = ttail(df ,abs(t_ew_`x'_`i'))*2
					}
				}
			}
        }


