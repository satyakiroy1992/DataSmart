#Wordcloud

library(tm)
library(SnowballC)
library(wordcloud)
dest <- "/Users/satyakiroy/Documents/R/pdfs/"

jeopCorpus <- Corpus(DirSource(dest, pattern = "txt"))

jeopCorpus <- tm_map(jeopCorpus, PlainTextDocument)
jeopCorpus <- tm_map(jeopCorpus, removePunctuation)
jeopCorpus <- tm_map(jeopCorpus, removeWords, stopwords('english'))
jeopCorpus <- tm_map(jeopCorpus, stemDocument)

wordcloud(jeopCorpus, max.words = 100, random.order = FALSE)



