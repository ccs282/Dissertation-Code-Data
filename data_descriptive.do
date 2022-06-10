** mean log returns
	
	summ ln_return_eua_settle if date >= 20071003 & date <= 20140205 // compare to Deeney et al. (2016); mean -0.000815; SD 0.03294; min -0.43208; max 0.24525; obs 1625
	
	summ ln_return_eua_settle if date >= 20080324 & date <= 20121019 // compare to Kemden et al. (2016); mean −0.000866; SD 0.026732; min −0.116029; max 0.245247; obs 1194
		
	summ ln_return_eua_settle if date >= 20080314 & date <= 20140430 // compare to Koch et al. (2014); mean -0.23 [-.00088123 daily]; SD 0.56 [.03466313 daily]; annualised values!!! for log returns, divide by 261; for SD divide by sqrt(261); assume 261 trading days (my calcuations)
	di -0.23/261
	di 0.56/sqrt(261)
	
	* explanatory variables
		foreach var of global ln_return_explanatory { 
			summ `var' if date >= 20080314 & date <= 20120430 // compare to Koch et al. (2014)
			di "mean `var':"
			di r(mean)*261
			di "SD `var':"
			di r(sd)*sqrt(261)
		}
		
		
		/*count if date >= 20080314 & date <= 20090313
		count if date >= 20090314 & date <= 20100313
		count if date >= 20100314 & date <= 20110313
		count if date >= 20110314 & date <= 20120313
		count if date >= 20120314 & date <= 20130313
		count if date >= 20130314 & date <= 20140313*/
	
