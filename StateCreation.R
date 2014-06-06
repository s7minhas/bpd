### THIS FILE IS AN INITIAL ATTEMPT TO CREATE THE FRAME 
## FOR PANEL DATASETS WHICH TAKE INTO ACCOUNT FORMATION
## AND BREAKUP OF STATES

rm(list=ls())

setwd('~/Desktop/Research/BuildingPanelData')
require(cshapes)
require(countrycode)

years <- seq(1960,2012,1)
date <- paste(years, '-12-31', sep='')

# Constructing data with GW and COW codes
# Function to extract country-year info from cshapes
vars <- c('CNTRY_NAME', 'COWCODE', 'GWCODE')
panel <- NULL

for(ii in 1:length(date)){
	if(years[ii]==2012){
		codesYear <- attributes(cshp(date=as.Date('2012-6-30'), useGW=TRUE))[['data']][,vars]
		panel <- rbind(panel, cbind(codesYear, years[ii])); colnames(panel) <- c(vars, 'year')
	} else {
		codesYear <- attributes(cshp(date=as.Date(date[ii]), useGW=TRUE))[['data']][,vars]
		panel <- rbind(panel, cbind(codesYear, years[ii])) } 
	if(ii==1 | ii%%10==0 | ii==length(date)){print(date[ii])} }

# Modifications
panel$CNTRY_NAME <- as.character(panel$CNTRY_NAME)

# countrycode reads Congo, DRC as Republic of Congo
panel[panel$CNTRY_NAME=='Congo, DRC','CNTRY_NAME'] <- 'Congo, Democratic Republic of'

# Adding in countrycode countryname and a ccode
panel$cname <- countrycode(panel$CNTRY_NAME, 'country.name', 'country.name')
panel$ccode <- panel$GWCODE

	# Subjective modifications
	# Yemen
	yem <- c("Yemen Arab Republic", "Yemen People's Republic", "Yemen")
	panel[which(panel$CNTRY_NAME %in% yem),]
	panel[panel$CNTRY_NAME=="Yemen People's Republic",'cname'] <- 'S. YEMEN'	

	# Yugoslavia Issues
	panel[panel$CNTRY_NAME=='Yugoslavia'|panel$CNTRY_NAME=='Serbia'|panel$CNTRY_NAME=='Serbia and Montenegro'|panel$CNTRY_NAME=='Montenegro',]
	# Equating Serbia with Yugoslavia
	panel[panel$CNTRY_NAME=='Serbia', 'ccode'] <- 345
	panel[panel$cname=='Yugoslavia', 'cname'] <- 'SERBIA'

	# Equating Czech Republic with Czechoslovakia
	panel[panel$CNTRY_NAME=='Czech Republic', 'ccode'] <- 315
	panel[panel$cname=='Czechoslovakia', 'cname'] <- 'CZECH REPUBLIC'

	# Vietnam
	panel[panel$CNTRY_NAME=='Republic of Vietnam','cname'] <- 'S. VIETNAM'	

# Discrepancies between COWCODE and GWCODEs
unique(panel[panel$COWCODE != panel$GWCODE,'CNTRY_NAME'])
############################################################

############################################################
# cntry-year identifier
panel$ccodeYear <- paste(panel$ccode, panel$year, sep='')
panel$cnameYear <- paste(panel$cname, panel$year, sep='')

# saving dataframe to datafolder
save(panel, file='panel.rda')
############################################################