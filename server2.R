library(shiny)
library(tm)
library(wordcloud)
library(RColorBrewer)
library(dplyr)      # for %>% and other dplyr functions
library(syuzhet)
library(cognizer)
library(curl)
library(rmsfact)
library(testthat)

pwcColors <- c("#ffb600", "#eb8c00", "#dc6900", "#e0301e", 
               "#db536a", "#a32020", "#602320", "#968c6d", "#3F3F40")

shinyServer(function(input, output) {
  observeEvent(input$submitDir, {
    audios <- list.files(input$dest1, full.names = TRUE)
    #trace("audio_text", edit=TRUE)
    audio_transcript <- audio_text(audios, "61cea374-62d7-47b4-97df-d2f61009ae16:v5eYyylfXZI2")
    str(audio_transcript)
    
    results <- (audio_transcript[[1]]$results)$alternatives
    
    total_transcript <- " "
    for(i in 1:length(results)){
      total_transcript <- paste(results[[i]]$transcript, total_transcript, sep = " ")
    }
    
    #docDF  <- readtext(input$dest1)
    corp<-Corpus(VectorSource(total_transcript)) 
    data<-tm_map(corp,stripWhitespace)
    
    data<-tm_map(data,tolower)
    
    data<-tm_map(data,removeNumbers)
    
    data<-tm_map(data,removePunctuation)
    
    data<-tm_map(data,removeWords, stopwords('english'))
    
    tdm<-TermDocumentMatrix (data ) #Creates a TDM
    
    
    TD<-as.matrix(tdm) #Convert this into a matrix format
    
    d <- findFreqTerms(tdm, lowfreq = 4)
    
    v = sort(rowSums(TD), decreasing = TRUE)
    
    output$plot1 <- renderPlot({wordcloud (data, scale=c(5,0.5), max.words=100, random.order=FALSE, 
                                           rot.per=0.35, use.r.layout=FALSE, colors=pwcColors)})
    
    m <- as.matrix(tdm)
    v <- sort(rowSums(m),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    output$plot2 <- renderPlot({barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
                                        col =rainbow(70),
                                        ylab = "Word frequencies")})
    
    s_v <- get_sentences(total_transcript)
    s_v_sentiment  <- get_sentiment(s_v, method="syuzhet")
    dct_values <- get_dct_transform(
      s_v_sentiment, 
      low_pass_size = 5, 
      x_reverse_len = 100,
      scale_vals = F,
      scale_range = T
    )
    
    output$plot3 <- renderPlot({plot(
      dct_values, 
      type ="l", 
      main ="Transformed Values", 
      xlab = "Narrative Time", 
      ylab = "Emotional Valence", 
      col = "red"
    )})
    nrc_data <- get_nrc_sentiment(s_v)
    pander::pandoc.table(nrc_data[, 1:8], split.table = Inf)
    output$plot4 <- renderPlot({barplot(
      sort(colSums(prop.table(nrc_data[, 1:8]))), 
      horiz = TRUE, 
      cex.names = 0.7, 
      las = 1, 
      main = "Emotions in Document", xlab="Percentage",
      col= rev(heat.colors(ncol(nrc_data)))
      
    )
    })
  }
  )

  
  
})
