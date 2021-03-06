rm(list=ls())

setwd('C:/Users/Owner/Research/bpd')
library(cshapes)
library(countrycode)
library(magrittr)
library(doParallel)
library(foreach)

years <- seq(1946,2016,1)
date <- paste(years, '-12-31', sep='')

# Constructing data with GW and COW codes
# Function to extract country-year info from cshapes
vars <- c('CNTRY_NAME', 'COWCODE', 'GWCODE')
panel <- NULL

cl = makeCluster(20)
registerDoParallel(cl)
panel = foreach(ii = 1:length(date), .packages=c('cshapes')) %dopar% {
	if(years[ii]==2016){
		codesYear <- attributes(cshp(date=as.Date('2016-6-30'), useGW=TRUE))[['data']][,vars]
		out = cbind(codesYear, year=years[ii])
	} else {
		codesYear <- attributes(cshp(date=as.Date(date[ii]), useGW=TRUE))[['data']][,vars]
		out = cbind(codesYear, year=years[ii])
	}
}
stopCluster(cl)

# org
panel = do.call('rbind', panel)
panel = data.frame(panel, stringsAsFactors=FALSE)

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
	panel[
		panel$CNTRY_NAME=='Yugoslavia'|
		panel$CNTRY_NAME=='Serbia'|
		panel$CNTRY_NAME=='Serbia and Montenegro'|
		panel$CNTRY_NAME=='Montenegro',]
	# Equating Serbia with Yugoslavia
	panel[panel$CNTRY_NAME=='Serbia', 'ccode'] <- 345
	panel[panel$cname=='Yugoslavia', 'cname'] <- 'SERBIA'

	# Equating Czech Republic with Czechoslovakia
	panel[panel$CNTRY_NAME=='Czech Republic', 'ccode'] <- 315
	panel[panel$cname=='Czechoslovakia', 'cname'] <- 'CZECH REPUBLIC'

	# Vietnam
	panel[panel$CNTRY_NAME=='Republic of Vietnam','cname'] <- 'S. VIETNAM'

# Discrepancies between COWCODE and GWCODEs
unique(panel[panel$COWCODE != panel$GWCODE,'CNTRY_NAME']) %>% cbind()
############################################################

############################################################
# assume 2017-2019 = 2016
yrs = 2017:2019
toAdd = lapply(yrs, function(yr){
	p = panel[panel$year==2016,]
	p$year = yr
	return(p) }) %>%
	do.call('rbind', .)

# add to panel
panel = rbind(panel, toAdd)
############################################################

############################################################
# cntry-year identifier
panel$ccodeYear <- paste(panel$ccode, panel$year, sep='')
panel$cnameYear <- paste(panel$cname, panel$year, sep='')
############################################################

############################################################
# saving dataframe to datafolder
save(panel, file='panel.rda')
############################################################
