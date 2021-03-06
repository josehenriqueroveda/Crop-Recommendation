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

crop_data <- crop_data %>%
  mutate(culture = factor(culture))

crop_data %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped",
                full_width = F,
                font_size = 14)

summary(crop_data)

##############################################################################
#                           ANÁLISE EXPLORATÓRIA                             #
##############################################################################

# PLOTAGENS PARA CADA VARIÁVEL
# Separando "input" e "output"
x <- crop_data[,1:7]
y <- crop_data[,8]

# Box-Plot para cada atributo
par(mfrow=c(1,7), mar=c(2,2,2,2))
  for (i in 1:7) {
    boxplot(x[,i], main=names(crop_data)[i])
  }

# PLOTAGENS PARA O CONJUNTO
# Histograma dos atributos
ggplot(gather(crop_data[1:7]), aes(value, fill=key)) + 
  geom_histogram(bins = 10) + 
  facet_wrap(~key, scales = 'free_x')

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

# ===================== VALIDAÇÃO DE ALGUNS ALGORÍTIMOS =====================#
# Criação de uma lista com 80% das observações do dataset original para treino
validation_index <- createDataPartition(crop_data$culture, p=0.80, list=FALSE)
# Selectionando 20% dos dados para validação
validation <- crop_data[-validation_index,]
# Os 80% restantes serão usados para treinar e testar os modelos
crop_data2 <- crop_data[validation_index,]
# Test Harness
# Validação cruzada para estimar a acurácia
control <- trainControl(method="cv", number=10)
metric <- "Accuracy"

# ==== Testes em 4 algoritmos diferentes:
# Linear Discriminant Analysis (LDA).
# Classification and Regression Trees (CART).
# k-Nearest Neighbors (kNN).
# Support Vector Machines (SVM) with a linear kernel.

# a) Algorítmos lineares
set.seed(7)
fit.lda <- train(culture~., data=crop_data2, method="lda", metric=metric, trControl=control)
# b) nonlinear algorithms
# CART
set.seed(7)
fit.cart <- train(culture~., data=crop_data2, method="rpart", metric=metric, trControl=control)
# kNN
set.seed(7)
fit.knn <- train(culture~., data=crop_data2, method="knn", metric=metric, trControl=control)
# c) advanced algorithms
# SVM
set.seed(7)
fit.svm <- train(culture~., data=crop_data2, method="svmRadial", metric=metric, trControl=control)

# ================= COMPARANDO E ESCOLHENDO O MELHOR MODELO =================#
results <- resamples(list(lda=fit.lda, cart=fit.cart, knn=fit.knn, svm=fit.svm))
summary(results)

dotplot(results)

# SVM se mostrou o com melhor acurácia
print(fit.svm)

# ============================ FAZENDO PREDIÇÕES ============================#
predictions <- predict(fit.svm, validation)
confusionMatrix(predictions, validation$culture)

# Podemos ver que a precisão é de 100%. 
# Foi um pequeno conjunto de dados de validação (20%)
# Mas este resultado está dentro da nossa margem esperada de 97% +/- 4%, 
# sugerindo que podemos ter um modelo preciso e confiável.

# Jose Henrique Roveda