#configurar argumentos na linha de comando
args <- commandArgs(trailingOnly = TRUE)

#leitura da bula
bula <- read.csv(args[1], sep = '\t', encoding = "utf-8")

#conversão do atributo token_id para character
bula$token_id <- as.character(bula$token_id)


#conversão para numeric
bula$token_id <- as.numeric(bula$token_id)
#bula$token_id

#Lista de palavras que comumente aparecem nas bulas para indicação 
palavrinhas <- c("indicado", "indicada", "recomendado", "recomendada", "utilizado", "utilizada", "destinado", "destinada") #palavras mágicas de receitas

#Seleciona as linhas nas quais as palavras da lista acima aparecem
select <- bula[which(bula$token %in% palavrinhas), ]
#select
y <- as.data.frame(select)

#Abaixo, selecionam-se os identificadores do particípio a ser procurado

#Seleção de doc_id
id_doc <- select$doc_id


#Seleção de sentence_id
id_frase <- select$sentence_id


#Selecao do token_id das palavras usuais de indicação
id_part <- select$token_id

#Seleciona as palavras que vêm depois da palavra de indicação
words <- bula[bula$doc_id == id_doc & bula$sentence_id == id_frase & bula$token_id > select$token_id, "token"]

para_que <- paste(words, collapse = " ")

#Refazer as contrações
para_que <- gsub(" de a ", " da ", para_que)
para_que <- gsub(" de o ", " do ", para_que)
para_que <- gsub(" a a ", " à ", para_que)
para_que <- gsub(" em a ", " na ", para_que)
para_que <- gsub(" em o ", " no ", para_que)
para_que <- gsub(" a o ", " ao ", para_que)
para_que <- gsub(" de as ", " das ", para_que)
para_que <- gsub(" de os ", " dos ", para_que)
para_que <- gsub(" de a ", " da ", para_que)
para_que <- gsub(" a as ", " às ", para_que)
para_que <- gsub(" a os ", " aos ", para_que)
para_que <- gsub(" em as ", " nas ", para_que)
para_que <- gsub(" em os ", " nos ", para_que)
para_que <- gsub("NA", " ", para_que)
#cat(args[1])
#cat("é indicado para:")

para_que
