// Set WD

cd "C:\Users\jonas\OneDrive - London School of Economics\Documents\LSE\GY489_Dissertation\LETS GO\Data"

// Import data
clear all
import delimited "Data.csv"


// Prep data
d

label variable mo1_px_last "EUA [Last]"
label variable mo1_px_settle "EUA [Settlememt]"
label variable co1_px_last "European Crude [Last]"
label variable co1_px_settle "European Crude [Settlement]"
label variable xa1_px_last "European Coal [Last]"
label variable xa1_px_settle "European Coal [Settlement]"
label variable tzt1_px_last "Gas TTF [Last]"
label variable tzt1_px_settle "Gas TTF [Settlement]"
label variable gi1_px_last "DE/AT Base [Last]"
label variable gi1_px_settle "DE/AT Base [Settlement]"
label variable vix_px_last "VIX Index (volatility)"
label variable stoxx_px_last "STOXX 600 Europe (stocks)"
label variable aaa_px_last "Moody AAA Corp"
label variable baa_px_last "Moody BAA Corp"
label variable diff_baa_aaa "Credit Spread"
label variable car1_px_last "CER CDM [last]"
label variable car1_px_settle "CER CDM [settlement]"
label variable gsci_px_last "GSCI (commodity)"
label variable ecb_spot_3m "Gov Bond Yield 3M"

global explanatory co1_px_last xa1_px_last tzt1_px_last gi1_px_last vix_px_last stoxx_px_last diff_baa_aaa car1_px_last gsci_px_last ecb_spot_3m

foreach var of global explanatory {
	capture drop `var'_ln
	gen `var'_ln = ln(`var')
}

capture drop mo1_px_settle_ln
gen mo1_px_settle_ln = ln(mo1_px_settle)



// Make dates state compatible

capture drop year month day stata_date
gen year = int(date/10000) 
gen month = int((date-year*10000)/100) 
gen day = int((date-year*10000-month*100)) 
gen stata_date = mdy(month,day,year)
order stata_date, after(date)
format stata_date  %td

drop if year <= 2007

capture drop trading_date
gen trading_date = 1
replace trading_date = trading_date[_n-1] + 1 if _n != 1



// prep time series
//tsset stata_date, d
tsset trading_date, d



	// create lagged dependent variable
forvalues i=1(1)100 {
	capture drop mo1_px_last_lag`i'
	gen mo1_px_last_lag`i' = .
	replace mo1_px_last_lag`i' = mo1_px_last[_n-`i']
}
	//capture drop mo1_px_last_lag*


// Data Descriptive

/*
xcorr mo1_px_last co1_px_last 
xcorr gsci_px_last diff_baa_aaa 
xcorr tzt1_px_last co1_px_last 
*/

// Returns generation

global explanatory_ln co1_px_last_ln xa1_px_last_ln tzt1_px_last_ln gi1_px_last_ln vix_px_last_ln stoxx_px_last_ln diff_baa_aaa_ln car1_px_last_ln gsci_px_last_ln ecb_spot_3m_ln

global explanatory_ln_D D.co1_px_last_ln D.xa1_px_last_ln D.tzt1_px_last_ln D.gi1_px_last_ln D.vix_px_last_ln D.stoxx_px_last_ln D.diff_baa_aaa_ln D.car1_px_last_ln D.gsci_px_last_ln D.ecb_spot_3m_ln


reg mo1_px_last $explanatory, robust
reg mo1_px_last mo1_px_last_lag60 $explanatory, robust
reg mo1_px_settle L60.mo1_px_last $explanatory, robust
reg mo1_px_settle $explanatory, robust

reg mo1_px_settle $explanatory_ln_D, robust
reg D.mo1_px_settle_ln $explanatory_ln_D, robust


// Italy coal phase-out announcement 24.10.2017
capture drop italy_announce
gen italy_announce = .
replace italy_announce = 1 if year == 2017 & month == 10 & day == 24
summ trading_date if italy_announce == 1
di r(mean)
gen italy_event



// Estudy command

estudy 


