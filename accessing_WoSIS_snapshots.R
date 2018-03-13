## from ttp://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/76f1bae3-cee1-4bc7-98b2-beb036d88d2b
## get ftp://public:public@ftp.isric.org/wosis_snapshot/WoSIS_2016_July.zip
## unzip WoSIS_2016_July.zip

# load data
setwd("D:/CGIAR/Da Silva, Mayesse Aparecida (CIAT) - Digital Soil Mapping Training India 2017/Training/Day1/Exercises/Gathering_available_global_soil_data/WoSIS/WoSIS_2016_July")
attributes = read.table("wosis_201607_attributes.txt", sep="\t",quote = "", header=TRUE)
profiles = read.table("wosis_201607_profiles.txt", sep="\t",quote = "", header=TRUE)
layers = read.table("wosis_201607_layers.txt", sep="\t", quote="", header=TRUE)

dim(attributes)
dim(profiles)
dim(layers)

colnames(attributes)
colnames(profiles)
colnames(layers)

# display data
attributes[1:22, 1:5]
profiles[1:10, 1:6]
layers[1:10, 1:6]

# merge profiles with layers
mer <- merge(x = profiles, y = layers, by = "profile_id", all = TRUE)
sel <- mer[mer$country_name=="India" & !is.na(mer[,"orgc_value_avg"]),]
sel <- sel[order(sel$profile_id, sel$top, sel$bottom),]

dim(sel)

# plot data
hist(log(sel[,"orgc_value_avg"]))
plot(sel$longitude, sel$latitude)

# write selection
write.csv(sel, file="./orgc_value_avg_India.csv")
