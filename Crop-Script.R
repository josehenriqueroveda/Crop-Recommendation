##################################################################################
#                         INSTALL AND LOAD PACKAGES                              #
##################################################################################
#Pacotes utilizados
pacotes <- c("plotly","tidyverse","knitr","kableExtra","fastDummies","rgl","car",
             "reshape2","jtools","lmtest","caret","pROC","ROCR","nnet","magick")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T) 
} else {
  sapply(pacotes, require, character = T) 
}

##############################################################################
#                             CROP RECOMENDATION                             #
##############################################################################

crop_data <- read_csv("Crop_recommendation.csv")

glimpse(crop_data)

crop_data$culture <- as.factor(crop_data$culture)

crop_data %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped",
                full_width = F,
                font_size = 14)

summary(crop_data)
