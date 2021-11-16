# load reef grid
load("../compiled_data/spatial_data/grid.RData")

## rcurl to pull data
## 90 day means
## ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211111/cfsv2_mean-90d_gbr_reef-id_20211106.nc
## hot snaps
## ftp://ftp.star.nesdis.noaa.gov/pub/sod/mecb/gliu/caldwell/20211111/cfsv2_hotsnap_gbr_reef-id_20211106.nc
x <- brick("../raw_data/covariate_data/CRW_dz_temp_metrics/cfsv2_mean-90d_gbr_reef-id_20211106.nc")

x2 <- x@data@names
unique(x2)

plot(x2)

x@file
str(x2)
head(reefsDF$ID)


t <- brick("../raw_data/covariate_data/CRW_dz_temp_metrics/cfsv2_hotsnap_gbr_reef-id_20211106.nc")


# ID number
t$X2459527@extent@xmax

#### this is where the values are stored ###
### Each "column" (X245...) = 1 day
### In each "column" there are 28 values for each pixel in GBR (total = 4808 pixels)
### Since it's unlikely we'll get nowcasts, we can use 16 weeks in future
### First day = Nov. 8, maybe start next week? Or maybe use Nov. 1 - 20 as "nowcast"?
### but that doesn't totally work with setup, unless we use average all all forecasts?
j <- t$X2459527
dim(j)
j[,1,]

unique(j)
unique(j@data@unit)

# day - based on last day of 7-day initial condition period (Oct 31-6), 239 total
# first day = Nov. 8, 2021
j@z
2459765 - 2459527
