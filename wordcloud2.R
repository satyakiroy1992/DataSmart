library(tm)

library(wordcloud)

library(RColorBrewer)

filePath = ???/Users/satyakiroy/Documents/R/pdfs//AnnexureD-Documentsrequiredatthetimeofjoining-1.txt???

txt = readLines(filePath)
corp<-Corpus(VectorSource(txt))  

data<-tm_map(corp,stripWhitespace)

data<-tm_map(data,tolower)

data<-tm_map(data,removeNumbers)

data<-tm_map(data,removePunctuation)

data<-tm_map(data,removeWords, stopwords(???english???))