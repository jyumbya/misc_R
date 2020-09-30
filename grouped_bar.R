library(ggplot2)

wards <- c(rep("makutano" , 3) , rep("napara" , 3) , rep("kingadole" , 3))
county <- rep(c("bungoma" , "busia" , "kakamega") , 3)
value <- abs(rnorm(9 , 0 , 15))
data <- data.frame(wards,county,value)

ggplot(data, aes(fill=county, y=value, x=wards)) + 
  geom_bar(position="dodge", stat="identity")+
  scale_fill_brewer(palette = "Set1")


library(lattice)
barchart(wards~value,data=data,groups=county, 
         scales=list(x=list(rot=90,cex=0.8)))
