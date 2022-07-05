	

    ** Results matrices
        if test_specific_date != "yes" {
            foreach x in Germany UK Spain Italy Czech_Republic Netherlands France Romania Bulgaria Greece Others {
				if `x'_num != 0 {
					local temp = `x'_num
					forvalues i = 1(1)`temp' {
                        matrix def `x'_phases = (CAR_pre_`x'_`i', CAR_event_`x'_`i', CAR_post_`x'_`i', CAR_ew_`x'_`i'\ SD_CAR_pre_`x'_`i', SD_CAR_event_`x'_`i', SD_CAR_post_`x'_`i', SD_CAR_ew_`x'_`i' \ p_pre_`x'_`i', p_event_`x'_`i', p_post_`x'_`i', p_ew_`x'_`i')
                        matrix rown `x'_phases = CAR SD p-value
                        matrix coln `x'_phases = CAR_pre CAR_event CAR_post CAR_window
                        summ date if date == announce_date[`x'_row, `i'], meanonly
                        matlist `x'_phases, lines(rct) title("`x'_`i': Pre/Post/Event/Event_Window (`r(mean)')")

                        * Individual days within event window
                            if show_days == 1 {
                                local pre = event_length_pre
                                local post = event_length_post
                                matrix def `x'_days = J(3, event_length_post+event_length_pre+1, .)

                                forvalues t = -`pre'(1)`post' {
                                    local nom = `t' + event_length_pre + 1
                                    matrix `x'_days[1, `nom'] = CAR_d`nom'_`x'_`i'
                                    matrix `x'_days[2, `nom'] = SD_CAR_event_`x'_`i'
                                    matrix `x'_days[3, `nom'] = p_d`nom'_`x'_`i'
                                }

                                matrix rown `x'_days = CAR SD p-value
                                summ date if date == announce_date[`x'_row, `i'], meanonly

                                matlist `x'_days, lines(rowt) title("`x'_`i': Individual Days (`r(mean)')")
                            }
					}
				}
			}
        
            * Average values 
                matrix def avg_phases = (CAR_pre_avg, CAR_event_avg, CAR_post_avg, CAR_ew_avg\ SD_CAR_pre_avg, SD_CAR_event_avg, SD_CAR_post_avg, SD_CAR_ew_avg \ p_pre_avg, p_event_avg, p_post_avg, p_ew_avg)
                matrix rown avg_phases = CAR SD p-value
                matrix coln avg_phases = CAR_pre_avg CAR_event_avg CAR_post_avg CAR_window_avg

                if show_days == 1 {
                    matrix def avg_days = J(3, event_length_post+event_length_pre+1, .)

                    forvalues t = -`pre'(1)`post' {
                        local nom = `t' + event_length_pre + 1
                        matrix avg_days[1, `nom'] = CAR_d`nom'_avg
                        matrix avg_days[2, `nom'] = SD_CAR_event_avg
                        matrix avg_days[3, `nom'] = p_d`nom'_avg
                    }
                    matrix rown avg_days = CAR SD p-value

                    matlist avg_days, lines(rowt) title("Individual Days [average]")
                }

                matlist avg_phases, lines(rct) title("Pre/Post/Event/Event_Window [average]")

        }

        else {
            matrix def results_phases = (CAR_pre, CAR_event, CAR_post, CAR_ew\ SD_CAR_pre, SD_CAR_event, SD_CAR_post, SD_CAR_ew \ p_pre, p_event, p_post, p_ew)
            matrix rown results_phases = CAR SD p-value
            matrix coln results_phases = CAR_pre CAR_event CAR_post CAR_window

            * Individual days within event window
            if show_days == 1{

                matrix def results_days = J(3, event_length_post+event_length_pre+1, .)

				local pre = event_length_pre
				local post = event_length_post

                forvalues t = -`pre'(1)`post' {
                    local nom = `t' + event_length_pre + 1
                    matrix results_days[1, `nom'] = CAR_d`nom'
                    matrix results_days[2, `nom'] = SD_CAR_event
                    matrix results_days[3, `nom'] = p_d`nom'
				}

                matrix rown results_days = CAR SD p-value
                local temp = date_specific
                matlist results_days, lines(rowt) title("Individual Days [`temp']")

            }
                local temp = date_specific
                matlist results_phases, lines(rct) title("Pre/Post/Event/Event_Window [`temp']")
        }