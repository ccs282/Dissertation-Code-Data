
** Tables
local estimation_length = est_length
local xx = event_length_post+event_length_pre+1
local regtype = reg_type
local xxx = No
asdoc matlist output_phases, replace save(`estimation_length'_`xx'_`regtype'_`xxx'.doc)
asdoc matlist output_days, append save(`estimation_length'_`xx'_`regtype'_`xxx'.doc)

** Graphs
capture drop CAR*
capture drop dev_graph

forvalues t = -$pre(1)$post {
    local nom = `t' + event_length_pre + 1
    capture gen dev_graph = . 
    replace dev_graph = `t' if _n == `nom'
}


foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
	foreach y in main alt new rev follow leak canc parl nuc {
		forvalues i = 1(1)10 {
			capture confirm scalar `x'_`y'`i'_d
			if _rc == 0 {
                forvalues t = -$pre(1)$post {
                    local nom = `t' + event_length_pre + 1
                    capture gen CAR_`x'_`y'`i' = .
                    replace CAR_`x'_`y'`i' = CAR`nom'_`x'_`y'`i' if _n == `nom'
			    }
			}
		}
	}
}

forvalues t = -$pre(1)$post {
    local nom = `t' + event_length_pre + 1
    capture gen CAR_avg = .
    replace CAR_avg = CAR_d`nom'_avg if _n == `nom'
}
