require(dplyr)
require(psych)
require(stringr)
require(caret)
require(data.table)
require(ggplot2)

analise.perfil <- fread(file = "C:/ProjetosUnimed/Arquivos (.txt, .csv)/
                        Base Perfil Saúde/Descritiva - Sankhia.txt",
                        na.strings = "",
                        colClasses = c("Codigo" = "character"))

perfil.sankhia <- analise.perfil %>% filter(`Plano atual` != 
                                              "Não possui") %>%
  select(-Tipo,-Quem,-Origem,-`Data Cadastro`)

perfil.sankhia$IMC <- str_replace_all(perfil.sankhia$IMC, ",", "\\.")
perfil.sankhia$Peso <- str_replace_all(perfil.sankhia$Peso, ",", "\\.")
perfil.sankhia$Altura <- str_replace_all(perfil.sankhia$Altura,
                                         ",", "\\.")

perfil.sankhia$IMC <- as.numeric(perfil.sankhia$IMC)
perfil.sankhia$Peso <- as.numeric(perfil.sankhia$Peso)
perfil.sankhia$Altura <- as.numeric(perfil.sankhia$Altura)

perfil.sankhia$inside.imc <- if_else(perfil.sankhia$IMC >= 25,
                                     "Acima do Peso",if_else(
                                       perfil.sankhia$IMC <= 20,
                                       "Abaixo do Peso","Ideal"))

perfil.sankhia$faixa.etaria <-if_else(perfil.sankhia$Idade < 19,"00 a 18",
                              if_else(perfil.sankhia$Idade < 24,"19 a 23",
                              if_else(perfil.sankhia$Idade < 29,"24 a 28",
                              if_else(perfil.sankhia$Idade < 34,"29 a 33",
                              if_else(perfil.sankhia$Idade < 39,"34 a 38",
                              if_else(perfil.sankhia$Idade < 44,"39 a 43",
                              if_else(perfil.sankhia$Idade < 49,"44 a 48",
                              if_else(perfil.sankhia$Idade < 54,"49 a 53",
                              if_else(perfil.sankhia$Idade < 59,
                                       "59 ou mais", "ERRO")))))))))

perfil.sankhia <- perfil.sankhia %>% select(
  -Carteira,-Empresa,-Nome) %>% distinct()

#### DESCRITIVA ####

sexo.imc <- table(perfil.sankhia$Sexo,perfil.sankhia$inside.imc)

plot(sexo.imc)

depressao <- table(perfil.sankhia$Deprimido,
                   perfil.sankhia$`Acompanhamento Psicológico`)

barplot(depressao)

cancer <- table(perfil.sankhia$Câncer)

bariatrica <- table(perfil.sankhia$`Cirugia Bariátrica`)

pulmao <- table(perfil.sankhia$`Doença Pulmonar`)

internado <- table(perfil.sankhia$Internado)

  vacina.dia <- table(perfil.sankhia$`Cartão Vacina em Dia`)

pie(vacina.dia)

cartao.vacina <- table(perfil.sankhia$`Cartão Vacina`)

pie(cartao.vacina)

pressao <- table(perfil.sankhia$`Pressão Alta`)

barplot(pressao)

alergia <- table(perfil.sankhia$Alergia)

pie(alergia)

limitacao <- table(perfil.sankhia$Limitação)

fumante <- table(perfil.sankhia$Fumante)

barplot(fumante, legend = c("N" = "Não", "P" = "Parou", "S" = "Sim"))

dor.pers <- table(perfil.sankhia$`Possui dor persistente`)

pie(dor.pers)

alcool <- table(perfil.sankhia$`Faz uso de álcool`)

pie(alcool)

alcool2 <- table(perfil.sankhia$`Álcool Frequência`)

pie(alcool2)

atividade.fisica <- table(perfil.sankhia$`Faz atividade física`)

atividade.fisica2 <- table(perfil.sankhia$`Atividade física`)

pie(atividade.fisica, col = c("darkred","darkblue","darkgreen"), 
    main = "Faz Atividade Física", 
    labels = (prop.table(atividade.fisica)*100))

diabetes <- table(perfil.sankhia$Diabetes)

idades <- table(perfil.sankhia$faixa.etaria)

media.idade <- perfil.sankhia %>% group_by(Sexo) %>%
  summarise(idade.media = mean(Idade))

ggplot(perfil.sankhia, aes(x=Idade,color=Sexo))+ 
  geom_density()+
  geom_vline(data=media.idade, aes(xintercept=idade.media, color=Sexo),
             linetype="dashed")+
  ggtitle("Incidência da Idade")+
  labs(y="Densidade")+theme_light()+
  theme(plot.title = element_text(color="black",size=14,
                                  face="bold.italic",hjust = 0.5),
        legend.title = element_blank())

media.imc <- perfil.sankhia %>% group_by(Sexo) %>%
  summarise(imc.medio = mean(IMC))

ggplot(perfil.sankhia, aes(x=IMC,color=Sexo))+ 
  geom_density()+
  geom_vline(data=media.imc, aes(xintercept=imc.medio, color=Sexo),
             linetype="dashed")+
  ggtitle("Incidência do IMC")+
  labs(y="Densidade")+theme_light()+
  theme(plot.title = element_text(color="black",size=14,
                                  face="bold.italic",hjust = 0.5),
        legend.title = element_blank())

perfil.sankhia$exames <- if_else(
  perfil.sankhia$`Exame de Citopatologia` == "S", "S", 
  if_else(perfil.sankhia$`Exame de Colesterol` == "S", "S", 
          if_else(perfil.sankhia$`Exame de Colonoscopia` == "S", "S",
                  if_else(
                    perfil.sankhia$`Exame de Esforcofisico` == "S", "S",
                    if_else(
                      perfil.sankhia$`Exame de Glicose` == "S", "S",
                      if_else(
                        perfil.sankhia$`Exame de Mamografia` == "S", "S",
                        if_else(
                          perfil.sankhia$`Exame de Prostata` == "S", "S",
                          if_else(
          perfil.sankhia$`Exame de Sangue oculto` == "S", "S", "N"))))))))

table(perfil.sankhia$exames)

perfil.sankhia$parentes <- if_else(
  perfil.sankhia$`Renal (pais)` == "S", "S", 
  if_else(perfil.sankhia$`Câncer (pais)` == "S", "S", 
          if_else(perfil.sankhia$`Cardíaco (pais)` == "S", "S",
                  if_else(
                    perfil.sankhia$`Diabetes (pais)` == "S", "S",
                    if_else(
                      perfil.sankhia$`Hipertensão (pais)` == "S", "S",
                      if_else(
                        perfil.sankhia$`Alzheimer (pais)` == "S", "S",
                        if_else(
                       perfil.sankhia$`Hipertensão (irmãos)` == "S", "S",
                          if_else(
          perfil.sankhia$`Diabetes (irmãos)` == "S", "S", 
          if_else(perfil.sankhia$`Renal (irmãos)` == "S", "S",
                  if_else(
                    perfil.sankhia$`Alzheimer (irmãos)` == "S", "S",
                    if_else(perfil.sankhia$`Câncer (irmãos)` == "S", "S",
                            if_else(
            perfil.sankhia$`Cardíaco (irmãos)` == "S", "S","N"))))))))))))

table(perfil.sankhia$parentes)

#### testes #####

data <- perfil.sankhia %>% 
  group_by(`Faz atividade física`) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(per=`n`/sum(`n`)) %>% 
  arrange(desc(`Faz atividade física`))

data$label <- scales::percent(data$per)

ggplot(data=data)+
  geom_bar(aes(x="", y=per, fill=`Faz atividade física`),
           stat="identity", width = 1)+
  coord_polar("y", start=0, direction = -1)+
  theme_void()+
  geom_text(aes(x=1, y = cumsum(per) - per/2, label=label))+
  scale_fill_manual(values = c("lightgreen","coral3", "#56B4E9"),
                    labels = c("Contra-Indicação", "Não", "Sim"))+
  guides(fill = guide_legend(reverse=TRUE))+
  ggtitle("Faz Atividade Física?")+
  theme(plot.title = element_text(color="black",size=14,
                              face="bold.italic",hjust = 0.5),
        legend.title = element_blank())
######## sankhia ######

names(perfil.sankhia)[names(
  perfil.sankhia) == "Codigo"] <- "Beneficiario Codigo"

custo.sankhia <- inner_join(despesas.dyad, perfil.sankhia, 
                    by = "Beneficiario Codigo")

custo.p.benef.sank <- custo.sankhia %>% group_by(
  `Beneficiario Codigo`) %>% summarise(
    Valor = sum(Guia.ProcedimentoVlrPagoAjustado))

mensal.sankhia <- custo.sankhia %>% group_by(Competencia) %>% summarise(
  Custo = sum(Guia.ProcedimentoVlrPagoAjustado, na.rm = T))

prob.internacao <- fread("C:/Users/mrrezende/Documents/
                         Prob. Internacao.csv",
                         na.strings = "",
                         colClasses = c(
                           "Beneficiario Codigo" = "character"))

prob.inter.sankhia <- inner_join(custo.p.benef.sank,prob.internacao,
                                 by = "Beneficiario Codigo")

fwrite(prob.inter.sankhia, 
       file = "C:/Users/mrrezende/Documents/Sankhia - Probabilidades.csv",
       sep = "|")


######## colaboradores ######

colaboradores <- fread("C:/ProjetosUnimed/Arquivos (.txt, .csv)/
                       Base Perfil Saúde/Colaboradores.txt")

colab2 <- fread("C:/Users/mrrezende/Documents/Codigo_Colab.txt",
                colClasses = c("Beneficiario Codigo" = "character"))

names(colaboradores)[names(
  colaboradores) == "CPF"] <- "Beneficiario CNP"

custo.colab <- inner_join(despesas.dyad, colab2, 
                            by = "Beneficiario Codigo")

custo.p.benef.colab <- custo.colab %>% group_by(
  `Beneficiario Codigo`) %>% summarise(
    Valor = sum(Guia.ProcedimentoVlrPagoAjustado, na.rm = T))

mensal.colab <- custo.colab %>% group_by(Competencia) %>% summarise(
  Custo = sum(Guia.ProcedimentoVlrPagoAjustado, na.rm = T))

prob.internacao <- fread("C:/Users/mrrezende/Documents/
                         Prob. Internacao.csv",
                         na.strings = "",
                         colClasses = c(
                           "Beneficiario Codigo" = "character"))

prob.inter.colab <- inner_join(custo.p.benef.colab,prob.internacao,
                                 by = "Beneficiario Codigo")

test.colab <- fread("C:/Users/mrrezende/Documents/teste_colab.txt",
                    colClasses = c("Beneficiario Codigo" = "character"))

teste <- left_join(prob.inter.colab, test.colab,
                   by = "Beneficiario Codigo")

fwrite(teste, file = "C:/Users/mrrezende/Documents/Benef_Perfil.csv",
       sep = "|",dec = ",")

fwrite(prob.inter.colab, 
       file = "C:/Users/mrrezende/Documents/Colab - Probabilidades.csv",
       sep = "|")

### correlacao colaboradores##

require(corrplot)

testes <- fread("C:/Users/mrrezende/Documents/teste.txt")

correl <- cor(testes$`P(Internação=Sim)`,testes$`Valor Gasto`,
              method = "spearman")

matriz <- testes %>% select(Idade,`Qtde PS`,`Qtde Espec`,
                            `Valor Gasto`,`P(Internação=Sim)`)

disper <- cor(matriz, method = "spearman")

corrplot(disper, diag = F, type = "upper",tl.srt=45)

########## eletrosom #########

eletrosom <- fread("C:/Users/mrrezende/Documents/codigos_eletrosom.txt",
                   colClasses = c("Beneficiario Codigo" = "character"))

custo.eletrosom <- inner_join(despesas.dyad, eletrosom, 
                          by = "Beneficiario Codigo")

custo.p.benef.eletrosom <- custo.eletrosom %>% group_by(
  `Beneficiario Codigo`) %>% summarise(
    Valor = sum(Guia.ProcedimentoVlrPagoAjustado, na.rm = T))

mensal.eletrosom <- custo.eletrosom %>% group_by(
  Competencia) %>% summarise(
  Custo = sum(Guia.ProcedimentoVlrPagoAjustado, na.rm = T))

prob.internacao <- fread("C:/Users/mrrezende/Documents/
                         Prob. Internacao.csv",
                         na.strings = "",
                         colClasses = c(
                           "Beneficiario Codigo" = "character"))

prob.inter.eletrosom <- inner_join(custo.p.benef.eletrosom,
                                   prob.internacao,
                               by = "Beneficiario Codigo")

perfil_eletrosom <- fread(
  "C:/Users/mrrezende/Documents/codigos_eletrosom_detalhados.txt",
                    colClasses = c("Beneficiario Codigo" = "character"))

juncao_perfil_prob <- left_join(prob.inter.eletrosom, perfil_eletrosom,
                   by = "Beneficiario Codigo")

fwrite(juncao_perfil_prob, 
       file = "C:/Users/mrrezende/Documents/Benef_Perfil_Prob_elet.csv",
       sep = "|",dec = ",")

fwrite(prob.inter.eletrosom, 
       file = "C:/Users/mrrezende/Documents/Eletros - Probabilidades.csv",
       sep = "|")

### correlacao eletrosom##

require(corrplot)

prob_ele <- fread("C:/Users/mrrezende/Documents/custoeprob_eletrosom.txt",
                  dec = ",")

correl <- cor(prob_ele$`P(Internação=Sim)`,prob_ele$`Valor`,
              method = "spearman")

matriz <- prob_ele %>% select(Idade,`Qtde PS`,`Qtde Espec`,
                            `Valor`,`P(Internação=Sim)`)

disper <- cor(matriz, method = "spearman")

corrplot(disper, diag = F, type = "upper",tl.srt=45)

########## algar ###########

algar <- fread("C:/Users/mrrezende/Documents/bases/algar_from_thais.txt",
               colClasses = c(
                 "Codigo" = "character"))

names(algar)[names(algar) == "Codigo"] <- "Beneficiario Codigo"

names(algar)[names(algar) == "Carteira"] <- "Código do Paciente"

algar$`Código do Paciente` <- NULL
algar$Nome <- NULL

custo.algar <- inner_join(despesas.dyad, algar, 
                          by = "Beneficiario Codigo")

custo.p.benef.algar <- custo.algar %>% group_by(
  `Beneficiario Codigo`) %>% summarise(
    Valor = sum(Guia.ProcedimentoVlrPagoAjustado, na.rm = T))

prob.algar <- inner_join(prob.internacao, algar,
                          by = "Beneficiario Codigo")

prob.algar2 <- inner_join(custo.p.benef.algar,prob.internacao, 
                         by = "Beneficiario Codigo")

teste <- anti_join(prob.algar,prob.algar2)

prob.algar.final <- bind_rows(prob.algar2,teste)

fwrite(prob.algar.final, 
       file = "C:/Users/mrrezende/Documents/Algar - Probabilidades.csv",
       sep = "|", dec = ",")

internacoes <- fread("C:/Users/mrrezende/Documents/internacoes.txt",
                     colClasses = c("Código do Paciente" = "character"))

internacoes.algar <- inner_join(algar,internacoes, 
                                by = "Código do Paciente")

fwrite(internacoes.algar,
       file = "C:/Users/mrrezende/Documents/Internacoes - Algar.csv",
       sep = "|", dec = ",")

falta.cartao <- fread("C:/Users/mrrezende/Documents/cartao.falta.txt",
                      colClasses = c("Beneficiario Codigo" = "character"))

busca.cartao <- inner_join(falta.cartao,despesas.dyad)

cartoes <- busca.cartao %>% select(`%NumeroCartao`) %>% distinct(.)

names(cartoes)[names(cartoes) == "%NumeroCartao"] <- "Código do Paciente"

faltantes <- inner_join(internacoes, cartoes,
                        by = "Código do Paciente")

fwrite(faltantes,
       file = "C:/Users/mrrezende/Documents/faltantes.csv",
       sep = ";", dec = ",")

