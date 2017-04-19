library(tm)

library(wordcloud)

library(RColorBrewer)


dest <- "/Users/satyakiroy/Documents/R/pdfs/"

txt = readLines(dest)
#corp<-Corpus(VectorSource(txt))  

corp<-Corpus(DirSource(dest, pattern = "txt")) 
data<-tm_map(corp,stripWhitespace)

data<-tm_map(data,tolower)

data<-tm_map(data,removeNumbers)

data<-tm_map(data,removePunctuation)

data<-tm_map(data,removeWords, stopwords('english'))

#wordcloud(data, max.words = 100, random.order = FALSE)

tdm<-TermDocumentMatrix (data) #Creates a TDM

TD<-as.matrix(tdm) #Convert this into a matrix format

v = sort(rowSums(TD), decreasing = TRUE)

wordcloud (data, scale=c(5,0.5), max.words=100, random.order=FALSE, rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, 'Dark2'))

