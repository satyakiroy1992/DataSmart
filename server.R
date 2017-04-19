library(shiny)
library(tm)
library(wordcloud)
library(RColorBrewer)
library(ggplot2)
library(fpc) 

shinyServer(function(input, output) {
  observeEvent(input$submitserverName, {
    x <- c('python', 'downloadFromUrl.py' , input$servername,paste0(c(input$dest1,'/'),collapse = ""))
    code1<- system(paste0(x,collapse = ' '))
    if(code1==0){
      ocr(output, input$dest1)
    }
  }
  )
  observeEvent(input$submitmail, {
    y <- c('python', 'gmailDownload.py' , input$dest2,input$username,input$password, input$label)
    code2<- system(paste0(y,collapse = ' '))
    if(code2==0){
      ocr(output, paste0(c(input$dest2,'/pdfs'),collapse = ""))
    }
    
  }
  )
  

})

ocr <- function(output, dest){
  
  
  #dest <- "/Users/satyakiroy/Documents/R/pdfs/"
  #dest = paste0(c(input$dest2,'/pdfs'),collapse = "")
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
  
  tdm<-TermDocumentMatrix (data ) #Creates a TDM

  
  TD<-as.matrix(tdm) #Convert this into a matrix format
  
  d <- findFreqTerms(tdm, lowfreq = 4)
  
  v = sort(rowSums(TD), decreasing = TRUE)
  
 # output$plot1 <- renderPlot({wordcloud (data, scale=c(5,0.5), max.words=100, random.order=FALSE, rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, 'Dark2'))})
  output$plot1 <- renderPlot({ wordcloud(names(v), v, min.freq=4, scale=c(5, .1), colors=brewer.pal(6, "Dark2"))})
   
  df <- data.frame(word = names(v),freq=v)
  # output$plot2 <- renderPlot({barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
  #                                     col =rainbow(70), main ="Most frequent words",
  #                                     ylab = "Word frequencies")})
  
  output$plot2 <- renderPlot({
    p <- ggplot(subset(df, freq>10), aes(word, freq))
    p <- p + geom_bar(aes(fill=freq),   # fill depends on cond2
                      stat="identity",
                      position=position_dodge())   
    p <- p + theme(axis.text.x=element_text(angle=45, hjust=1))   
    p
  })
  
  # dtmss <- removeSparseTerms(tdm, 0.15) # This makes a matrix that is only 15% empty space, maximum. 
  # print(tdm)
  # ds <- dist(t(tdm), method="euclidian")  
  # kfit <- kmeans(ds, 3)   
  # output$plot3 <- renderPlot({
  #   clusplot(as.matrix(ds), kfit$cluster, color=T, shade=T, labels=3, lines=0) 
  # })
  # 
  # 
  # dtm_tfxidf <- weightTfIdf(tdm)
  # 
  # ## do document clustering
  # 
  # ### k-means (this uses euclidean distance)
  # m <- as.matrix(dtm_tfxidf)
  # rownames(m) <- 1:nrow(m)
  # 
  # ### don't forget to normalize the vectors so Euclidean makes sense
  # norm_eucl <- function(m) m/apply(m, MARGIN=1, FUN=function(x) sum(x^2)^.5)
  # m_norm <- norm_eucl(m)
  # 
  # 
  # ### cluster into 10 clusters
  # cl <- kmeans(m_norm, 3)
  # cl
  # 
  # table(cl$cluster)
  # 
  # ### show clusters using the first 2 principal components
  # 
  # output$plot3 <- renderPlot({ plot(prcomp(m_norm)$x, col=cl$cl)})
  
  
}
