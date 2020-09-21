#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(lubridate)
library(dplyr)

# Define server logic required to draw a trend graph
shinyServer(function(input, output) {

    output$Plot <- renderPlot({
        if(input$metric=="Death rate"){
        
        # setup outside input 
        new<-read.csv(url("https://www.data.gouv.fr/fr/datasets/r/6fadff46-9efd-4c53-942a-54aca783c30c"),header=TRUE,sep=";")
        new$jour<-as.Date(new$jour,format="%Y-%m-%d")
        new$dep<-as.numeric(new$dep)
        nom<-read.csv("nom.csv",header = TRUE)
        new<-merge(new,nom,by="dep")
        
        # generate data table based on lookback and department input from ui.R
        if(input$department!="France"){
        dep<-new %>% filter(nom==as.character(input$department)) %>% filter(jour>=today()-days(input$lookback))
        ggplot(dep,aes(x=jour,y=incid_dc))+geom_point(colour="black",size=3,alpha=.5)+geom_smooth(method=lm)+ggtitle(paste("New daily death in last",input$lookback, "days in",dep$nom[1]))
        }else{
        alldep<-new %>% filter(jour>=today()-days(input$lookback)) %>% group_by(jour) %>% summarise(total=sum(incid_dc))
        ggplot(alldep,aes(x=jour,y=total))+geom_point(colour="black",size=3,alpha=.5)+geom_smooth(method=lm)+ggtitle(paste("New daily death in last",input$lookback, "days in France"))
        }
        }else if(input$metric=="Hospitalization rate"){
            # setup outside input 
            cumu<-read.csv(url("https://www.data.gouv.fr/fr/datasets/r/6fadff46-9efd-4c53-942a-54aca783c30c"),header=TRUE,sep=";")
            cumu$jour<-as.Date(cumu$jour,format="%Y-%m-%d")
            cumu$dep<-as.numeric(cumu$dep)
            nom<-read.csv("nom.csv",header = TRUE)
            cumu<-merge(cumu,nom,by="dep")
            
            # generate data table based on lookback and department input from ui.R
            if(input$department!="France"){
                dep<-cumu %>% filter(nom==as.character(input$department)) %>% filter(jour>=today()-days(input$lookback))
                ggplot(dep,aes(x=jour,y=incid_hosp))+geom_point(colour="black",size=3,alpha=.5)+geom_smooth(method=lm)+ggtitle(paste("New daily hospitalization in last",input$lookback, "days in",dep$nom[1]))
            }else{
                alldep<-cumu %>% filter(jour>=today()-days(input$lookback)) %>% group_by(jour) %>% summarise(total=sum(incid_hosp))
                ggplot(alldep,aes(x=jour,y=total))+geom_point(colour="black",size=3,alpha=.5)+geom_smooth(method=lm)+ggtitle(paste("New daily hospitalization in last",input$lookback, "days in France"))    
            }
        }else if(input$metric=="Mortality"){
            # setup outside input 
            cumu<-read.csv(url("https://www.data.gouv.fr/fr/datasets/r/63352e38-d353-4b54-bfd1-f1b3ee1cabd7"),header=TRUE,sep=";")
            cumu$jour<-as.Date(cumu$jour,format="%Y-%m-%d")
            cumu$dep<-as.numeric(cumu$dep)
            nom<-read.csv("nom.csv",header = TRUE)
            cumu<-merge(cumu,nom,by="dep")
            pop<-read.csv("population.csv",header = TRUE)
            pop$dep<-as.numeric(pop$dep)
            cumu<-merge(cumu,pop,by="dep")
            
            # generate data table based on lookback and department input from ui.R
            if(input$department!="France"){
                dep<-cumu %>% filter(sexe=="0") %>% filter(nom==as.character(input$department)) %>% filter(jour>=today()-days(input$lookback))
                ggplot(dep,aes(x=jour,y=dc/population*100000))+geom_point(colour="black",size=3,alpha=.5)+geom_smooth(method=lm)+ggtitle(paste("Mortality per 100,000 in last",input$lookback, "days in",dep$nom[1]))
            }else{
                alldep<-cumu %>% filter(jour>=today()-days(input$lookback)) %>% group_by(jour) %>% summarise(total=sum(dc)/sum(population)*100000)
                ggplot(alldep,aes(x=jour,y=total))+geom_point(colour="black",size=3,alpha=.5)+geom_smooth(method=lm)+ggtitle(paste("Mortality per 100,000 in last",input$lookback, "days in France"))    
            }
        }
    })
    
    output$map<-renderLeaflet({
    if(input$metric=="Hospitalization rate"){
        new<-read.csv(url("https://www.data.gouv.fr/fr/datasets/r/6fadff46-9efd-4c53-942a-54aca783c30c"),header=TRUE,sep=";")
        new$jour<-as.Date(new$jour,format="%Y-%m-%d")
        new$dep<-as.numeric(new$dep)
        nom<-read.csv("nom.csv",header = TRUE)
        new<-merge(new,nom,by="dep")
        dep<-new %>% filter(jour==today()-days(1))
        ave<-new %>% filter(jour>=today()-days(input$lookback))%>%group_by(dep)%>%summarise(ave=mean(incid_hosp))
        last<-merge(dep,ave,by="dep")
        couleurs <- colorNumeric("YlOrRd", dep$ave, n = 5)
        m<-leaflet()%>%addTiles()%>%addCircles(lng=last$lng,lat=last$lat,radius=last$ave*1000,color = couleurs(last$ave),fillOpacity = 0.9,popup=paste(last$nom,": ",last$ave)) %>% addLegend(pal=couleurs,values=last$ave,opacity=0.9,title = "Average hospitalization")
        m
    }else if (input$metric=="Death rate"){
        new<-read.csv(url("https://www.data.gouv.fr/fr/datasets/r/6fadff46-9efd-4c53-942a-54aca783c30c"),header=TRUE,sep=";")
        new$jour<-as.Date(new$jour,format="%Y-%m-%d")
        new$dep<-as.numeric(new$dep)
        nom<-read.csv("nom.csv",header = TRUE)
        new<-merge(new,nom,by="dep")
        dep<-new %>% filter(jour==today()-days(1))
        ave<-new %>% filter(jour>=today()-days(input$lookback))%>%group_by(dep)%>%summarise(ave=mean(incid_dc))
        last<-merge(dep,ave,by="dep")
        
        couleurs <- colorNumeric("YlOrRd", dep$ave, n = 5)
        m<-leaflet()%>%addTiles()%>%addCircles(lng=last$lng,lat=last$lat,radius=last$ave*10000,color = couleurs(last$ave),fillOpacity = 0.9,popup=paste(last$nom,": ",last$ave)) %>% addLegend(pal=couleurs,values=last$ave,opacity=0.9,title = "Average death")
        m
    }else if (input$metric=="Mortality"){
        cumu<-read.csv(url("https://www.data.gouv.fr/fr/datasets/r/63352e38-d353-4b54-bfd1-f1b3ee1cabd7"),header=TRUE,sep=";")
        cumu$jour<-as.Date(cumu$jour,format="%Y-%m-%d")
        cumu$dep<-as.numeric(cumu$dep)
        nom<-read.csv("nom.csv",header = TRUE)
        cumu<-merge(cumu,nom,by="dep")
        pop<-read.csv("population.csv",header = TRUE)
        pop$dep<-as.numeric(pop$dep)
        cumu<-merge(cumu,pop,by="dep")
        alldep<-cumu %>% filter(sexe=="0") %>% filter(jour==today()-days(1))
        ave<-cumu %>% filter(jour>=today()-days(input$lookback)) %>% group_by(dep) %>% summarise(ave=mean(dc/population*100000))
        last<-merge(alldep,ave,by="dep")
        
        couleurs <- colorNumeric("YlOrRd", dep$ave, n = 5)
        m<-leaflet()%>%addTiles()%>%addCircles(lng=last$lng,lat=last$lat,radius=last$ave*100,color = couleurs(last$ave),fillOpacity = 0.9,popup=paste(last$nom,": ",last$ave)) %>% addLegend(pal=couleurs,values=last$ave,opacity=0.9,title = "Average mortality")
        m
    }
    })
})
