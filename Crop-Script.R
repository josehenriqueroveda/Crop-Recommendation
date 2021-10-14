##################################################################################
#                            INSTALAÇÃO DOS PACOTES                              #
##################################################################################
#Pacotes utilizados
pacotes <- c("plotly","tidyverse","knitr","kableExtra","fastDummies","rgl","car",
             "reshape2","jtools","lmtest","caret","pROC","ROCR","nnet","magick",
             "GGally")

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

crop_data %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped",
                full_width = F,
                font_size = 14)

summary(crop_data)

##############################################################################
#                           ANÁLISE EXPLORATÓRIA                             #
##############################################################################
# Histograma dos atributos
ggplot(gather(crop_data[1:7]), aes(value, fill=key)) + 
  geom_histogram(bins = 10) + 
  facet_wrap(~key, scales = 'free_x')

crop_data <- crop_data %>%
  mutate(culture = factor(culture))

# Por cultura
crop_data %>% 
  pivot_longer(N:rainfall, names_to = "Feature", values_to = "value") %>% 
  ggplot(aes(x = value, fill = culture)) +
  geom_histogram(alpha = 0.7) +
  labs(x = "Value", y = "Count", fill = NULL) +
  theme_bw() +
  facet_wrap(~Feature, scales = "free")

# Density plots
crop_data %>% 
  pivot_longer(N:rainfall, names_to = "Feature", values_to = "value") %>% 
  ggplot(aes(x = value, fill = culture)) +
  geom_density(alpha = 0.5) +
  labs(fill = NULL) +
  theme_bw() +
  facet_wrap(~Feature, scales = "free")

# Box Plots
crop_data %>% 
  pivot_longer(N:rainfall, names_to = "Feature", values_to = "value") %>% 
  ggplot(aes(x = culture, y = value, fill = culture)) +
  geom_boxplot() +
  labs(x = "Population", y = "Count", fill = NULL) +
  theme_bw() +
  coord_flip() +
  facet_wrap(~Feature, scales = "free_x", ncol = 4) +
  theme(legend.position = "top")

# Entendendo a correlação entre os atributos
ggpairs(crop_data, columns = 1:7 ,title = "Correlação entre os atributos") 

crop_data %>%
  ggpairs(columns = 1:7, ggplot2::aes(colour=culture), 
          title = "Correlação entre os atributos por cultura") 
