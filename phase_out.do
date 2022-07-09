			

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

/*
if main == "yes" {
				scalar bg_main1 	= 1
				scalar bg_alt1 		= 0
				scalar cz_main1 	= 1
				scalar cz_new1 		= 0
				scalar dk_main1 	= 0
				scalar dk_new1 		= 0
				scalar fi_main1 	= 1
				scalar fi_alt1 		= 1
				scalar fi_alt2 		= 1
				scalar fi_parl1 	= 1
				scalar de_main1 	= 1
				scalar de_leak1 	= 1
				scalar de_canc1 	= 1
				scalar de_canc2 	= 1
				scalar de_parl1 	= 1
				scalar de_new1 		= 1
				scalar de_new2 		= 1
				scalar de_nuc1 		= 0
				scalar de_nuc2 		= 0
				scalar de_rev1 		= 1
				scalar el_main1 	= 1
				scalar el_new1 		= 1
				scalar hu_main1 	= 1
				scalar hu_alt1 		= 1
				scalar it_main1 	= 1
				scalar nl_main1 	= 1
				scalar nl_alt1 		= 1
				scalar nl_follow1 	= 1
				scalar pl_main1 	= 1
				scalar pt_main1 	= 1
				scalar pt_new1 		= 1
				scalar ro_main1 	= 1
				scalar ro_leak1 	= 1
				scalar ro_alt1 		= 1
				scalar sk_main1 	= 1
				scalar sk_alt1 		= 1
				scalar si_main1 	= 1
				scalar si_alt2 		= 1
				scalar si_alt1 		= 1
				scalar es_main1 	= 1
				scalar es_alt1 		= 1
				scalar es_alt2 		= 1
				scalar uk_main1 	= 1
				scalar uk_leak1 	= 1
				scalar uk_follow1 	= 1
				scalar uk_new1 		= 1
				scalar xx_main1 	= 0
				scalar xx_main2 	= 0
				scalar xx_main3 	= 0
} 


				scalar bg_main1 	= 1
				scalar bg_alt1 		= 1
				scalar cz_main1 	= 1
				scalar cz_new1 		= 1
				scalar dk_main1 	= 1
				scalar dk_new1 		= 1
				scalar fi_main1 	= 1
				scalar fi_alt1 		= 1
				scalar fi_alt2 		= 1
				scalar fi_parl1 	= 1
				scalar de_main1 	= 1
				scalar de_leak1 	= 1
				scalar de_canc1 	= 1
				scalar de_canc2 	= 1
				scalar de_parl1 	= 1
				scalar de_new1 		= 1
				scalar de_new2 		= 1
				scalar de_nuc1 		= 0
				scalar de_nuc2 		= 0
				scalar de_rev1 		= 1
				scalar el_main1 	= 1
				scalar el_new1 		= 1
				scalar hu_main1 	= 1
				scalar hu_alt1 		= 1
				scalar it_main1 	= 1
				scalar nl_main1 	= 1
				scalar nl_alt1 		= 1
				scalar nl_follow1 	= 1
				scalar pl_main1 	= 1
				scalar pt_main1 	= 1
				scalar pt_new1 		= 1
				scalar ro_main1 	= 1
				scalar ro_leak1 	= 1
				scalar ro_alt1 		= 1
				scalar sk_main1 	= 1
				scalar sk_alt1 		= 1
				scalar si_main1 	= 1
				scalar si_alt2 		= 1
				scalar si_alt1 		= 1
				scalar es_main1 	= 1
				scalar es_alt1 		= 1
				scalar es_alt2 		= 1
				scalar uk_main1 	= 1
				scalar uk_leak1 	= 1
				scalar uk_follow1 	= 1
				scalar uk_new1 		= 1
				scalar xx_main1 	= 0
				scalar xx_main2 	= 0
				scalar xx_main3 	= 0
				

foreach x in bg cz dk fi de el hu it nl pl pt ro sk si es uk xx {
	foreach y in main alt new rev follow leak canc parl nuc {
		forvalues i = 1(1)10 {
			capture confirm scalar `x'_`y'`i'_s
			if _rc == 0 {
				capture confirm variable `x'_`y'`i'
				if _rc == 0 {
					if `x'_`y'`i'_s == 1 {
						scalar `x'_`y'`i'_d = `x'_`y'`i'[1]
					}
				}
			}
		}
	}
}
*/
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








/*
matrix def announce_date = (20190128, 20180917, 20200116, 20211015, .\ 20151118, 20180105, 20201214, ., .\ 20181115, 20190222, 20200120, 20210630, . \ 20171024, 20190923, ., ., . \ 20201204, 20220107, ., ., . \ 20171010, 20160923, 20180518, ., . \ 20161115, 20160426, 20170706, ., . \ 20210526, 20210603, 20220531, ., . \ 20211011, ., ., ., . \ 20190923, 20210923, 20220406, ., . \ 20151118, 20151118, 20130124, ., .)
			
matrix rown announce_date = 1_Germany 2_UK 3_Spain 4_Italy 5_Czech_Republic 6_Netherlands 7_France 8_Romania 9_Bulgaria 10_Greece 11_Others
matrix coln announce_date = Date_Pref Date2 Date3 Date4 Date5
			
scalar Germany_row = 1
scalar UK_row = 2
scalar Spain_row = 3
scalar Italy_row = 4
scalar Czech_Republic_row = 5
// earlier deadline CZ
scalar Netherlands_row = 6
scalar France_row = 7
scalar Romania_row = 8
scalar Bulgaria_row = 9
// Bulgaria alt
scalar Greece_row = 10
scalar Others_row = 11
*/
