---
  title: "airbnb"
author: "Sara Kmair"
date: "10/8/2019"
output:
  word_document: default
html_document: default
---


## R Markdown

#libraries
library(corrplot)
library(ggplot2)
library(dplyr)
library(tidytext)
library(tm) # for text mining
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(bigmemory)



#checking the data and data structure
airbnb <- read.csv("airbnb.csv")
str(airbnb)


#changing id column from integer to char
airbnb$host_id <- as.character(airbnb$host_id)

#Delete id column and host_name as it has no influence in our analysis 
airbnb <- subset(airbnb, select = -c(id, host_name, availability_365))

#changing the name attribute to desc as it gives a small description about the listing
colnames(airbnb)[which(names(airbnb) == "name")] <- "description"
colnames(airbnb)[which(names(airbnb) == "calculated_host_listings_count")] <- "listing_cnt"
str(airbnb)

levels(airbnb$neighbourhood_group)

#checking how many neighbourhood in each neighbourhood group
airbnb %>%
  group_by(neighbourhood_group) %>%
  summarise(neighbourhood_number = n_distinct(neighbourhood))


#checking for NAs in the dataset
names(airbnb)
sum(is.na(airbnb$price))
sum(is.na(airbnb$minimum_nights))
sum(is.na(airbnb$availability_365))
sum(is.na(airbnb$calculated_host_listings_count))


#Manhattan is the most popular neighborhood 
ggplot(airbnb, aes(x =neighbourhood_group)) +
  geom_bar( fill = "cyan4", col = "grey20") 

#renting entire home seems the most popular type 
ggplot(airbnb, aes(x =room_type)) +
  geom_bar( fill = "pink", col = "grey20") 


#visualizing Average price in each neighbourhood by room_type
airbnb %>% 
  group_by(room_type, neighbourhood_group) %>%
  summarise(AvgPrice = mean(price)) %>%
  arrange(desc(AvgPrice)) %>%
  ggplot(., aes(x = neighbourhood_group, y = AvgPrice, fill = factor(room_type))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "", y = "Avg Price") +
  scale_fill_manual(values = c("cyan3", "purple", "hotpink")) +
  ggtitle("Avg Price In each Neighbourhood") +
  theme(plot.title = element_text(hjust = 0.5))



#The average price for each neighborhood group 
airbnb %>% 
  group_by(neighbourhood_group) %>%
  summarise(AvgPrice = mean(price)) %>%
  arrange(desc(AvgPrice))

#In this step we will study outliers for each neighbourhood and how it is affecting the price 
#subsetting Bronx neighbourhood
boxplot(price ~ neighbourhood_group, data = airbnb)
Bronx_sub <- airbnb[which(airbnb$neighbourhood_group == "Bronx"), ]
nrow(Bronx_sub)
summary(Bronx_sub$price)

#removing the ourliers from Bronx price 
out_Bronx <- boxplot(Bronx_sub$price, plot = FALSE)$out
length(out_Bronx)
mean(out_Bronx)
Bronx_sub %>%
  group_by(room_type) %>%
  summarise(mean(price))

Bronx_sub_no_out <- Bronx_sub[-  which(Bronx_sub$price %in% out_Bronx), ]
Bronx_out_only <- Bronx_sub[ which(Bronx_sub$price %in% out_Bronx), ]
Bronx_out_only %>%
  group_by(room_type) %>%
  summarise(length(room_type))
#the outliers are going to affect out analysis since mean is increasing by 17
#calculating the mean with and without outliers 
mean(Bronx_sub$price)
mean(out_Bronx)
mean(Bronx_sub_no_out$price)

#subsetting Brooklyn neighbourhood 
Brooklyn_sub <- airbnb[which(airbnb$neighbourhood_group == "Brooklyn"), ]
summary(Brooklyn_sub$price)
nrow(Brooklyn_sub)

#removing the ourliers from Brooklyn price 
out_Brooklyn <- boxplot(Brooklyn_sub$price, plot = FALSE)$out
length(out_Brooklyn)
mean(out_Bronx)
Brooklyn_sub %>%
  group_by(room_type) %>%
  summarise(mean(price))

Brooklyn_sub_no_out <- Brooklyn_sub[-  which(Brooklyn_sub$price %in% out_Brooklyn), ]
Bronoklyn_out_only <- Brooklyn_sub[ which(Brooklyn_sub$price %in% out_Brooklyn), ]
Bronoklyn_out_only %>%
  group_by(room_type) %>%
  summarise(length(room_type))

#Calculating the mean with and without outliers 
mean(Brooklyn_sub$price)
mean(out_Brooklyn)
mean(Brooklyn_sub_no_out$price)




#The most popular hosts and the number of times been rented 
top_host <- airbnb %>%
  group_by(host_id) %>%
  summarise( mcount = length(host_id), avgPrice = mean(price)) %>%
  arrange(desc(mcount)) %>%
  slice(1:10)

#top ten host 
top_host

#extracting the listings of the top hosts 
pop_host <- airbnb[which(airbnb$host_id == top_host$host_id), ] 
head(pop_host)

#visualizing top ten hosts and the number of listing counts for each with what room_type it is
#notice from the plot top ten most popular host hasonly entire home or private room that means shared room is not as popular 
ggplot(pop_host, aes(x = host_id, y = listing_cnt, fill = room_type)) +
  geom_bar(stat = "identity", position = "dodge", color = "purple" ) +
  labs(x = "", y = "listing counts") +
  coord_flip() +
  ggtitle("Top Ten Host") +
  theme(plot.title = element_text(hjust = 0.5))



ggplot(airbnb) +
  geom_dotplot(dotsize = 0.4, aes(x = airbnb$minimum_nights,fill = airbnb$room_type)) +
  coord_flip() +
  labs(y = "", x = "minimum nights") +
  scale_fill_manual(values = c("cyan3", "purple", "hotpink"))

hist(airbnb$minimum_nights, xlab = "minimum nights distribution", ylab = "", col = "cyan4", labels = FALSE)




#find the most expensive rent 
max_price <- max(airbnb$price)
airbnb[which(airbnb$price == max_price), ]

#let's study the most popular neighbourhood Manhattan
Manhattan <- airbnb[airbnb$neighbourhood_group == "Manhattan", ]
head(Manhattan)

Manhattan %>%
  group_by (room_type) %>%
  summarise(AvgPrice = mean(price)) #average prices in Manhattan





