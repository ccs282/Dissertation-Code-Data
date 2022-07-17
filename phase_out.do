			
save data, replace
import delimited "phase_outs.csv", clear

foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
	foreach y in main alt new rev follow leak canc parl nuc {
		forvalues i = 1(1)10 {
				capture confirm variable `x'_`y'`i'
				if _rc == 0 {
					scalar `x'_`y'`i'_s = `x'_`y'`i'[2]
					if `x'_`y'`i'_s == 1 {
						scalar `x'_`y'`i'_d = `x'_`y'`i'[1]
					}
				}
		}
	}
}

use data, clear

				foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
					foreach y in main alt new rev follow leak canc parl nuc {
						forvalues i = 1(1)10 {
							capture confirm scalar `x'_`y'`i'_d
							if _rc == 0 {
								summ date if date == `x'_`y'`i'_d
								if r(N) == 0 {
									tab date if date > `x'_`y'`i'_d, matrow(mat_temp)
									scalar `x'_`y'`i'_d = mat_temp[1, 1]
								}
							}
						}
					}
				}
