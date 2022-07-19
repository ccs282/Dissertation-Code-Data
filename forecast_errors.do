if price == "yes" {
	capture drop MSFE*
	capture drop RMSFE*
	capture drop MAFE*
	capture drop NR_*
	capture drop yhat*

	summ trading_date if date == 20090403
	scalar tempp = int((_N - r(mean)- 7 + event_length_post)/7) // correct?

    if no_windows <= tempp {
       local aux = no_windows*7 - 7
    }

    else {
        local aux = tempp*7
    }

	forvalues k = 0(7)`aux'{
			
    	summ trading_date if date == 20090403
            ** estimation window + event window for forecast error
            capture drop event_date_fe
            gen event_date_fe = .
            summ trading_date if date == 20090403
            replace event_date_fe = 1 if trading_date == r(mean) + `k'

            capture drop ew_fe
            gen ew_fe = .
            summ trading_date if event_date_fe == 1
            replace ew_fe = 1 if (trading_date >= r(mean) - event_length_pre) & (trading_date <= r(mean) + event_length_post)

            capture drop est_win_fe
            gen est_win_fe = .
            summ trading_date if event_date_fe == 1
            replace est_win_fe = 1 if (trading_date >= r(mean) - event_length_pre - est_length) & (trading_date < r(mean) - event_length_pre) & (date >= 20080401)
            
            foreach x in variables variables_2 variables_3 const_mean const_mean_trim zero_mean levels{
                
                ** generate predictions
                if  "`x'" == "variables" {
                    capture drop tempv 
                    summ trading_date if event_date_fe == 1
                    gen tempv = ln_return_eua if trading_date < (r(mean) - event_length_pre) 
                    reg tempv L.tempv $ln_return_explanatory if est_win_fe == 1, robust

                    local ew_length = event_length_post + event_length_pre + 1
                    forvalues i = 1(1)`ew_length' {
                        summ trading_date if event_date_fe == 1
                        predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        capture gen NR_`x'= .
                        replace NR_`x' = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                    }
                }

                else if "`x'" == "const_mean" {
                    reg ln_return_eua est_win_fe if est_win_fe == 1, robust noconst
                    gen NR_`x' = e(b)[1, 1]
                }

                else if "`x'" == "const_mean_trim" {
                    reg ln_return_eua est_win_fe if est_win_fe == 1, robust noconst
                    trimmean ln_return_eua if est_win_fe == 1, percent(20)
                    gen NR_`x' = r(tmean20)
                }

                else if "`x'" == "zero_mean" {
                    gen NR_`x' = 0

                }

                else if "`x'" == "levels" {
                    capture drop tempv 
                    summ trading_date if event_date_fe == 1
                    gen tempv = eua if trading_date < (r(mean) - event_length_pre) 
                    reg tempv L.tempv $explanatory if est_win_fe == 1, robust

                    local ew_length = event_length_post + event_length_pre + 1
                    forvalues i = 1(1)`ew_length' {
                        summ trading_date if event_date_fe == 1
                        predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        capture gen NR_`x'= .
                        replace NR_`x' = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                    }
                }

                else if  "`x'" == "variables_2" {
                    capture drop tempv 
                    summ trading_date if event_date_fe == 1
                    gen tempv = ln_return_eua if trading_date < (r(mean) - event_length_pre) 
                    reg tempv L.tempv $D_ln_return_explanatory_2 if est_win_fe == 1, robust

                    local ew_length = event_length_post + event_length_pre + 1
                    forvalues i = 1(1)`ew_length' {
                        summ trading_date if event_date_fe == 1
                        predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        capture gen NR_`x'= .
                        replace NR_`x' = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                    }
                }

                else if  "`x'" == "variables_3" {
                    capture drop tempv 
                    summ trading_date if event_date_fe == 1
                    gen tempv = ln_return_eua if trading_date < (r(mean) - event_length_pre) 
                    reg tempv L.tempv D_ln_return_oil D_ln_return_elec D_ln_return_gsci ln_return_vix D_ln_return_stoxx ln_return_diff_baa_aaa ln_return_ecb_spot_3m D_ln_return_gas D_ln_return_coal if est_win_fe == 1, robust

                    local ew_length = event_length_post + event_length_pre + 1
                    forvalues i = 1(1)`ew_length' {
                        summ trading_date if event_date_fe == 1
                        predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        capture gen NR_`x'= .
                        replace NR_`x' = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                    }
                }


                ** yhat, MSFE, RMSFE, MAFE

                capture gen yhat_`x' = . 
                replace yhat_`x' = NR_`x' if ew_fe == 1
                    
                capture drop NR_*

                if "`x'" != "levels" {
                    capture drop fe_`x' 
                    gen fe_`x' = yhat_`x' - ln_return_eua if ew_fe == 1
                }
                else {
                    gen fe_`x' = yhat_`x' - eua if ew_fe == 1

                }

                capture drop fe_abs_`x'
                gen fe_abs_`x' = abs(fe_`x')

                capture drop fe_squared_`x'
                gen fe_squared_`x' = fe_`x'^2

                capture gen MSFE_`x' = .
                summ fe_squared_`x'
                replace MSFE_`x' = r(mean) if event_date_fe == 1

                capture gen RMSFE_`x' = .
                replace RMSFE_`x' = sqrt(MSFE_`x')

                capture gen MAFE_`x' = .
                summ fe_abs_`x'
                replace MAFE_`x' =  r(mean) if event_date_fe == 1
                
                capture drop fe*
		    }
	}
}











if volume == "yes" {
    	capture drop MSFE*
	capture drop RMSFE*
	capture drop MAFE*
	capture drop NR_*
	capture drop yhat*

	summ trading_date if date == 20090403
	scalar tempp = int((_N - r(mean)- 7 + event_length_post)/7) // correct?

    if no_windows <= tempp {
       local aux = no_windows*7 - 7
    }

    else {
        local aux = tempp*7
    }

	forvalues k = 0(7)`aux'{
			
    	summ trading_date if date == 20090403
            ** estimation window + event window for forecast error
            capture drop event_date_fe
            gen event_date_fe = .
            summ trading_date if date == 20090403
            replace event_date_fe = 1 if trading_date == r(mean) + `k'

            capture drop ew_fe
            gen ew_fe = .
            summ trading_date if event_date_fe == 1
            replace ew_fe = 1 if (trading_date >= r(mean) - event_length_pre) & (trading_date <= r(mean) + event_length_post)

            capture drop est_win_fe
            gen est_win_fe = .
            summ trading_date if event_date_fe == 1
            replace est_win_fe = 1 if (trading_date >= r(mean) - event_length_pre - est_length) & (trading_date < r(mean) - event_length_pre) & (date >= 20080401)
            
            foreach x in variables const_mean const_mean_trim zero_mean levels{
                
                ** generate predictions
                if  "`x'" == "variables" {
                    capture drop tempv 
                    summ trading_date if event_date_fe == 1
                    gen tempv = ln_return_eua_vol if trading_date < (r(mean) - event_length_pre) 
                    reg tempv L.tempv $ln_return_explanatory if est_win_fe == 1, robust

                    local ew_length = event_length_post + event_length_pre + 1
                    forvalues i = 1(1)`ew_length' {
                        summ trading_date if event_date_fe == 1
                        predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        capture gen NR_`x'= .
                        replace NR_`x' = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                    }
                }

                else if "`x'" == "const_mean" {
                    reg ln_return_eua_vol est_win_fe if est_win_fe == 1, robust noconst
                    gen NR_`x' = e(b)[1, 1]
                }

                else if "`x'" == "const_mean_trim" {
                    reg ln_return_eua_vol est_win_fe if est_win_fe == 1, robust noconst
                    trimmean ln_return_eua_vol if est_win_fe == 1, percent(20)
                    gen NR_`x' = r(tmean20)
                }

                else if "`x'" == "zero_mean" {
                    gen NR_`x' = 0

                }

                else if "`x'" == "levels" {
                    capture drop tempv 
                    summ trading_date if event_date_fe == 1
                    gen tempv = eua_vol if trading_date < (r(mean) - event_length_pre) 
                    reg tempv L.tempv $explanatory if est_win_fe == 1, robust

                    local ew_length = event_length_post + event_length_pre + 1
                    forvalues i = 1(1)`ew_length' {
                        summ trading_date if event_date_fe == 1
                        predict NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        replace tempv = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                        capture gen NR_`x'= .
                        replace NR_`x' = NR_`i' if trading_date == (r(mean) - event_length_pre -1 + `i')
                    }
                }


                ** yhat, MSFE, RMSFE, MAFE

                capture gen yhat_`x' = . 
                replace yhat_`x' = NR_`x' if ew_fe == 1
                    
                capture drop NR_*

                if "`x'" != "levels" {
                    capture drop fe_`x' 
                    gen fe_`x' = yhat_`x' - ln_return_eua_vol if ew_fe == 1
                }
                else {
                    gen fe_`x' = yhat_`x' - eua_vol if ew_fe == 1

                }

                capture drop fe_abs_`x'
                gen fe_abs_`x' = abs(fe_`x')

                capture drop fe_squared_`x'
                gen fe_squared_`x' = fe_`x'^2

                capture gen MSFE_`x' = .
                summ fe_squared_`x'
                replace MSFE_`x' = r(mean) if event_date_fe == 1

                capture gen RMSFE_`x' = .
                replace RMSFE_`x' = sqrt(MSFE_`x')

                capture gen MAFE_`x' = .
                summ fe_abs_`x'
                replace MAFE_`x' =  r(mean) if event_date_fe == 1
                
                capture drop fe*
		    }
	}

}