	

    ** Results matrices
        if test_specific_date != "yes" {
            foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
                        matrix def `x' = (CAR_pre_`x'_`i', CAR_event_`x'_`i', CAR_post_`x'_`i', CAR_ew_`x'_`i'\ SD_CAR_pre_`x'_`i', SD_CAR_event_`x'_`i', SD_CAR_post_`x'_`i', SD_CAR_ew_`x'_`i' \ p_pre_`x'_`i', p_event_`x'_`i', p_post_`x'_`i', p_ew_`x'_`i')
                        matrix rown `x' = CAR SD p-value
                        matrix coln `x' = CAR_pre CAR_event CAR_post CAR_event_window
                        matrix list `x'
                                                di "`x'_`i'; "
                        summ date if date == announce_date[`x'_row, `i'], meanonly
                        di r(mean)
                        di "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

					}
				}
			}
        
            matrix def avg = (CAR_pre_avg, CAR_event_avg, CAR_post_avg, CAR_ew_avg\ SD_CAR_pre_avg, SD_CAR_event_avg, SD_CAR_post_avg, SD_CAR_ew_avg \ p_pre_avg, p_event_avg, p_post_avg, p_ew_avg)
            matrix rown avg = CAR SD p-value
            matrix coln avg = CAR_pre_avg CAR_event_avg CAR_post_avg CAR_ew_avg
            matrix list avg
        }

        else {
            matrix def results = (CAR_pre, CAR_event, CAR_post, CAR_ew\ SD_CAR_pre, SD_CAR_event, SD_CAR_post, SD_CAR_ew \ p_pre, p_event, p_post, p_ew)
            matrix rown results = CAR SD p-value
            matrix coln results = CAR_pre CAR_event CAR_post CAR_event_window
            matrix list results
            di date_specific
        }