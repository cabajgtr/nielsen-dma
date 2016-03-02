library(sp)
library(rgdal)
library(maptools)
library(rgeos)
library(ggplot2)
library(ggalt)
library(ggthemes)
library(jsonlite)
library(purrr)
library(viridis)
library(scales)

neil <- readOGR("nielsentopo.json", "nielsen_dma", stringsAsFactors=FALSE, 
                verbose=FALSE)
# there are some techincal problems with the polygon that D3 glosses over
neil <- SpatialPolygonsDataFrame(gBuffer(neil, byid=TRUE, width=0),
                                  data=neil@data)
neil_map <- fortify(neil, region="id")

tv <- fromJSON("tv.json", flatten=TRUE)
tv_df <- map_df(tv, as.data.frame, stringsAsFactors=FALSE, .id="id")
colnames(tv_df) <- c("id", "rank", "dma", "tv_homes_count", "pct", "dma_code")
tv_df$pct <- as.numeric(tv_df$pct)/100

gg <- ggplot()
gg <- gg + geom_map(data=neil_map, map=neil_map,
                    aes(x=long, y=lat, map_id=id),
                    color="white", size=0.05, fill=NA)
gg <- gg + geom_map(data=tv_df, map=neil_map,
                    aes(fill=pct, map_id=id),
                    color="white", size=0.05)
gg <- gg + scale_fill_viridis(name="% US", labels=percent)
gg <- gg + coord_proj(paste0("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96",
                             " +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"))
gg <- gg + theme_map()
gg <- gg + theme(legend.position="bottom")
gg <- gg + theme(legend.key.width=unit(2, "cm"))
gg
