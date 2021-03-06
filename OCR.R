

library(tm)
library(wordcloud)
library(RColorBrewer)
args = commandArgs(trailingOnly=TRUE)
#dest <- "/Users/satyakiroy/Documents/R/pdfs/"
dest = args[1]
# make a vector of PDF file names
myfiles <- list.files(path = dest, pattern = "pdf",  full.names = TRUE)
print( myfiles)


# PDF filenames can't have spaces in them for these operations
# so let's get rid of the spaces in the filenames

sapply(myfiles, FUN = function(i){
  file.rename(from = i, to =  paste0(dirname(i), "/", gsub(" ", "", basename(i))))
})

# get the PDF file names without spaces
myfiles <- list.files(path = dest, pattern = "pdf",  full.names = TRUE)

# Now we can do the OCR to the renamed PDF files. Don't worry
# if you get messages like 'Config Error: No display 
# font for...' it's nothing to worry about

lapply(myfiles, function(i){
  # convert pdf to ppm (an image format), just pages 1-10 of the PDF
  # but you can change that easily, just remove or edit the 
  # -f 1 -l 10 bit in the line below
  system( paste0("pdftoppm ", i, " -f 1 -l 10 -r 600 ocrbook") )
  # convert ppm to tif ready for tesseract
  system(paste0("convert *.ppm ", i, ".tif"))
  # convert tif to text file
  system(paste0("tesseract ", i, ".tif ", i, " -l spa"))
  # delete tif file
  file.remove(paste0(i, ".tif" ))
})


# And now you're ready to do some text mining on the text files

############### PDF (text format) to TXT ###################

# If you have a PDF with text, ie you can open the PDF in a 
# PDF viewer and select text with your curser, then use these 
# lines to convert each PDF file that is named in the vector 
# into text file is created in the same directory as the PDFs
# note that my pdftotext.exe is in a different location to yours
lapply(myfiles, function(i) system(paste('"pdftotext"', paste0('"', i, '"')), wait = FALSE) )


# And now you're ready to do some text mining on the text files

corp<-Corpus(DirSource(dest, pattern = "txt")) 
data<-tm_map(corp,stripWhitespace)

data<-tm_map(data,tolower)

data<-tm_map(data,removeNumbers)

data<-tm_map(data,removePunctuation)

data<-tm_map(data,removeWords, stopwords('english'))

tdm<-TermDocumentMatrix (data) #Creates a TDM

TD<-as.matrix(tdm) #Convert this into a matrix format

d <- findFreqTerms(tdm, lowfreq = 4)

v = sort(rowSums(TD), decreasing = TRUE)

wordcloud (data, scale=c(5,0.5), max.words=100, random.order=FALSE, rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, 'Dark2'))

m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
        col =rainbow(70), main ="Most frequent words",
        ylab = "Word frequencies")

