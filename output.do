
local estimation_length = est_length
local xx = event_length_post+event_length_pre+1
local regtype = reg_type
asdoc matlist output_phases, replace save(`estimation_length'_`xx'_`regtype'_raw.doc)
asdoc matlist output_days, append save(`estimation_length'_`xx'_`regtype'_raw.doc)
