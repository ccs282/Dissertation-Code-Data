			
matrix def announce_date = (20190128, 20180917, 20200116, 20211015, .\ 20151118, 20180105, 20201214, ., .\ 20181115, 20190222, 20200120, 20210630, . \ 20171024, 20190923, ., ., . \ 20201204, 20220107, ., ., . \ 20171010, 20160923, 20180518, ., . \ 20161115, 20160426, 20170706, ., . \ 20210526, 20210603, 20220531, ., . \ 20211011, ., ., ., . \ 20190923, 20210923, 20220406, ., . \ ., ., ., ., .)
			
matrix rown announce_date = 1_Germany 2_UK 3_Spain 4_Italy 5_Czech_Republic 6_Netherlands 7_France 8_Romania 9_Bulgaria 10_Greece 11_Others
matrix coln announce_date = Date_Pref Date2 Date3 Date4 Date5
			
scalar Germany_row = 1
scalar UK_row = 2
scalar Spain_row = 3
scalar Italy_row = 4
scalar Czech_Republic_row = 5
scalar Netherlands_row = 6
scalar France_row = 7
scalar Romania_row = 8
scalar Bulgaria_row = 9
scalar Greece_row = 10
scalar Others_row = 11

/*
NOTES
			
Generally: 1st date is the preferred date
				
1 (Germany): 
	1st date: should be 26 Jan 2019, 28 Jan is the next trading date
	2nd date : should be 15 Sept 2018, 17 Sept is the next trading date
2 (UK):
3 (Spain):
4 (Italy):
5 (Czech_Republic):
6 (Netherlands):
7 (France):
8 (Romania):
9 (Bulgaria):
10 (Greece):
11 (Others): 
*/

