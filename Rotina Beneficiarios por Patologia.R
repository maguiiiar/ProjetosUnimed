require(dplyr)
require(psych)
require(readxl)
require(data.table)
require(tidyr)
require(openxlsx)
require(stringr)

#setwd("C:/ProjetosUnimed/Arquivos (.txt, .csv)/
#Planilhas Espaço Viver Bem")

# benefppato <- read.xlsx("Beneficiarios por patologia.xlsx",sheet = 1, 
                         # startRow = 1, colNames = TRUE,na.strings ="NA")

setwd("C:/ProjetosUnimed/Arquivos (.txt, .csv)/
      Planilhas Espaço Viver Bem/2018/
      Estratificação mensal - Desospitalização 2018")

baseviver <- read.xlsx(
  "FOR EVB 080 - Estratificação Mensal Desospitalização -Janeiro.xlsx",
  sheet = 1,startRow = 5,rows = c(6:90), colNames = TRUE,na.strings ="NA")

baseviver <- baseviver %>% filter(Motivo.da.Saída != "Obito")

baseviver$Nº <- NULL

baseviver$Código.do.beneficiário <- as.character(
  baseviver$Código.do.beneficiário)

# benefppato$Inscrição.Beneficiário <- as.character(
#   benefppato$Inscrição.Beneficiário)
# 
# colnames(benefppato)[3] <- "Código.do.beneficiário"
# 
# buscapatolo <- left_join(
#baseviver,benefppato,by="Código.do.beneficiário")

# colnames(baseviver)[2] <- "%NumeroCartao"

# juncao <- left_join(baseviver,unif, by = "%NumeroCartao" )
# 
# juncao2 <- juncao %>% group_by(`%NumeroCartao`,Cliente) %>% summarise(
#   n=n())
# 
# qtdenas <- buscapatolo %>% group_by(Patologia) %>% summarise(n=n())

setwd("C:/ProjetosUnimed/Arquivos (.txt, .csv)/Bases R")

load("DRG com custo.RData")

names(dados.drg.custo)

dados.drg.custo2 <- dados.drg.custo %>%select(`Identificador do Paciente`,
                                              `Código do Paciente`,
                                              `Nome do Paciente`,
                                              `Data de Nascimento`,
                                               Sexo,
                                              `Situação da Internação`,
                                              `Caráter de Internação`,
                                              `Data de Internação`,
                                              `Data da Alta`,
                                              `Permanência Real`,
                                              `CID Principal`,
                                             `Descrição do CID Principal`,
                                              `Nome do Hospital`,
                                              `Custo Total (R$)`,
                                              `Custo Médio Diárias Após`)

# dados.drg.custo2$`Data de Nascimento` <- as.Date(
#   dados.drg.custo2$`Data de Nascimento`,"%d/%m/%Y")
# 
# dados.drg.custo2$`Data de Internação` <- as.Date(
#   dados.drg.custo2$`Data de Internação`,"%d/%m/%Y")
# 
# dados.drg.custo2$`Data da Alta` <- as.Date(
#   dados.drg.custo2$`Data da Alta`,"%d/%m/%Y")
# 
# dados.drg.custo2$TempoInter <- dados.drg.custo2$`Data da Alta`- 
#   dados.drg.custo2$`Data de Internação`
# 
# dados.drg.custo2$TempoInter <- as.numeric(dados.drg.custo2$TempoInter)
# 
# dados.drg.custo2$TempoInter <- dados.drg.custo2$TempoInter+1
dados.drg.custo2$`Custo Total (R$)` <- 
  dados.drg.custo2$`Custo Total (R$)`+1

dados.drg.custo3 <- dados.drg.custo2 %>% group_by(Sexo,
                                        `Situação da Internação`,
                                        `CID Principal`) %>% summarise(
                                         TempoMedio = geometric.mean(
                                         `Permanência Real`, na.rm = T),
                                         CustoMedio = geometric.mean(
                                         `Custo Total (R$)`,na.rm = T))

# dados.drg.custo3$TempoMedio <- dados.drg.custo3$TempoMedio-1
dados.drg.custo3$CustoMedio <- dados.drg.custo3$CustoMedio-1

dados.drg.custo2$`Custo Total (R$)` <- 
  dados.drg.custo2$`Custo Total (R$)`-1
# dados.drg.custo2$TempoInter <- dados.drg.custo2$TempoInter-1

# dados.drg.custo2$TempoInter <- ifelse(dados.drg.custo2$TempoInter < 1, 
#                                       1,dados.drg.custo2$TempoInter)
# 
# dados.drg.custo2$`Permanência Real` <- ceiling(
#   dados.drg.custo2$`Permanência Real`)

valor.diaria.media.drg <- dados.drg.custo2 %>% group_by(Sexo,
                                          `Situação da Internação`,
                                          `CID Principal`) %>% summarise(
DiariaMedia = sum(`Custo Total (R$)`,na.rm = T)/sum(`Permanência Real`,
                                                    na.rm = T))

vlrs.drg <- left_join(dados.drg.custo3,valor.diaria.media.drg,
                      by=c("Sexo","CID Principal",
                           "Situação da Internação"))

vlrs.drg <- vlrs.drg %>% filter(`CID Principal` == c(""))

write.file(vlrs.drg,file = "valoresDRG.txt", sep = ";")

setwd("C:/ProjetosUnimed/Arquivos (.txt, .csv)/Planilhas Espaço Viver Bem")

dados.viverbem <- fread("Pacientes Internação Domiciliar.csv",sep = ";")

dados.viverbem <- dados.viverbem %>% select(Nome,Sexo,`Codigo Usuário`,
                                            `dif dias`,`Custo Hospitalar`,
                                           `CID 10`,`Patologia Principal`)

dados.viverbem$Empresa <- as.numeric(dados.viverbem$`Custo Hospitalar`)

dados.viverbem2 <- dados.viverbem %>% group_by(Sexo,
                                               `CID 10`) %>% summarise(
                                              TempoMedio = geometric.mean(
                                              `dif dias`, na.rm = T),
                                              CustoMedio = geometric.mean(
                                                `Custo Hospitalar`,
                                                na.rm = T),
                                              DiariaMedia = 
                                                sum(`Custo Hospitalar`)/
                                                sum(`dif dias`))

write.file(dados.viverbem2, file = "valoresEVB.txt",sep = ";")
