	
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

