
##Una web en shiny tiene 3 elementos, UI, server interface y función shiny

### Cargamos los paquetes que sean necesarios ###

#Instalación de paquetes:

# List of packages for session
.packages = c("shiny", "shinythemes", "RColorBrewer", "lattice", "reshape2", "googleVis", "flowCore", "bit", "CytoTree", "ggplot2", "ggthemes", "plotly", "devtools", "DynTxRegime", "modelObj", "shinydashboard", "shinydashboardPlus", "reticulate", "this.path", "rMIDAS", "BiocManager", "LSD", "tcltk", "gplots", "graphics", "e1071", "lle", "vegan", "tabplot", "shinybusy")
#this.path->localizar scripts
#reticulate-> uso de python dentro de R
#rMIDAS -> para poder fijar el env de python

# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])


# Load packages into session -> #ALICIA: entiendo que con esta línea podría eliminar todas las de library()
lapply(.packages, require, character.only=TRUE)



#library(shiny)
#library(shinythemes)
#library(RColorBrewer)
#library(lattice)
#library(reshape2)
#library(googleVis)
#library(flowCore)
#library(bit)
#library(CytoTree)
#library(ggplot2)
#library(ggthemes)
#library(plotly)
#library(DynTxRegime)
#library(modelObj)

#ALICIA: este paquete teniendo en cuenta que da problemas lo pongo de forma independiente
if("tabplot" %in% rownames(installed.packages()) == FALSE) {install_github("mtennekes/tabplot")}
if("reticulate" %in% rownames(installed.packages()) == FALSE){devtools::install_github("rstudio/reticulate")} #necesario instalarlo así, sino da errores luego cuando usamos reticulate
if("CytoTree" %in% rownames(installed.packages()) == FALSE){devtools::install_github("JhuangLab/CytoTree")}
if("flowAI" %in% rownames(installed.packages()) == FALSE){BiocManager::install("flowAI")}

###cargamos las funciones auxiliares
source("global.R") ##este es el script auxiliar que contiene funciones del módulo FlowiQC y de cytotree, son funciones que pueden ser llamadas por iu o server
##GENPATTERN -PYTHON
#Para evitar problemas de inconpatibilidades de versiones de python, trabajaremos desde un entorno específico para esta app
if("r-reticulate" %in% virtualenv_list() == FALSE) {virtualenv_create("r-reticulate")}
use_virtualenv("r-reticulate") #indicamos que use este entorno

#system("sudo apt install python3.8-venv")  #Desmarcar si es necesario, yo tuve que hacerlo para que me dejase tener pip en el entorno virtual
#system(" .virtualenvs/r-reticulate/bin/python -m ensurepip") 
#instalamos el módulo de genepattern de python
#if (import("gp")== FALSE) {virtualenv_install("r-reticulate", packages = "genepattern-python")} 
virtualenv_install("r-reticulate", packages = "genepattern-python") #opto por esta opción ya que da menos problemas de instalación
gp <-import("gp") #cargamos genepattern



###### INVOCAR PYTHON Y GENEPATTERM 
current_dir <-this.dir() #marco el directorio actual
path_python_scripts <-paste(current_dir, "/python/", sep = "") #busco la carpeta python donde guardo mis scripts de python
##para el previewfcs 
script_preprocessing<-paste(path_python_scripts, "FCS_preprocessing.py", sep="") #busco el script de FCS_preprocessing.py
source_python(script_preprocessing) #lo cargo en r con esta función de reticulate


### Creo la UI (User interface) ####
#este apartado es el que corresponde a la apariencia gráfica de la web. 

ui<- fluidPage(theme=shinytheme("cerulean"), 
               add_busy_spinner(spin="fulfilling-bouncing-circle"), ###COMENTARIO ALICIA, dependiendo del tipo de spinner que se use me da errores una parte u otra; si uso double-bounce o fading-spin, la parte de quality va bien, pero gating no. Si uso "radar" gating va bien, pero quality no
               #van bien con gating:flower, pixel, spring,fulfilling-bouncing-circle, semipolar,
               #van bien con quality:circle
               #funciona con ambas cosas:fulfilling-square, 
               
               titlePanel("FLOW CYTOMETRY ANALYSIS SERVER"), #título de la web
               navbarPage( "",
                           collapsible = TRUE, #para que cambie la vista en pantallas más pequeñas
                           windowTitle = "Cytometry Biotechvana",
                           
                           
                           tabPanel("Home", icon=icon("home"), #esto corresponde a la página principal o de inicio
                                    fluidRow(
                                      
                                      h3("Welcome to Biotechvana Flow Cytometry Server!"),
                                      p("Here you you can find several tools to asses your journey of flow cytometry Data analysis:"),
                                      
                                      column(
                                        br(), br(), br(),
                                        tags$img(src="fcs-files.png", width="110px", height="110px"),
                                        width=2),
                                      column(
                                        br(), br(), br(),br(),br(),
                                        tags$img(src="flecha.png", width="30px", height="30px"),
                                        width = 1),
                                      column(
                                        br(),
                                        h4("Data PreProcesing"),
                                        p("Includes modules to evaluate initial data and  conversion between formats"),
                                        width = 2),
                                      column(
                                        br(), br(), br(),br(),br(),
                                        tags$img(src="flecha.png", width="30px", height="30px"),
                                        width = 1),
                                      column(
                                        br(),
                                        h4("Quality Assessment"),
                                        p("It includes several tools to assess the quality of the FCS data"),
                                        width = 2),
                                      column(
                                        br(), br(), br(),br(),br(),
                                        tags$img(src="flecha.png", width="30px", height="30px"),
                                        width = 1),
                                      column(
                                        br(),
                                        h4("Clustering"),
                                        p("Here you can find tools for manual gating as well as several clustering algorithms"),
                                        width = 2),
                                      column(
                                        width = 1)
                                    )
                           ),
                           navbarMenu("Data preprocessing",
                                      tabPanel("FCS Preview",
                                               h3("Module for PreviewFCS"),
                                               br(),
                                               h5(strong("Description:")),
                                               p("Allows viewing of structural metadata, parameters, and descriptive statistics from a Flow Cytometry Standard (FCS) data file"),
                                               hr(),
                                               fluidRow(
                                                 column(3, #lado izquierdo con todos los botones interactivos
                                                        h5("Parameters:"),
                                                        fileInput('previewFCSfile', strong('Choose fcs file:'), multiple = FALSE, #de momento que el archivo sea único, en una mejora se podría mirar para meter varios 
                                                                  accept = c('text/fcs', '.fcs')),
                                                        br(),
                                                        actionButton("go_fcspreview", "Submit!"),
                                                        hr(),
                                                        div(style = "margin-top: 30px; width: 200px; ", HTML("Based on an implementation of GenePattern 2.0 Nature Genetics 38 no. 5 (2006): pp500-501 Google Scholar | Endnote | RIS")),
                                                        div(style = "margin-top: 10px; ", 
                                                            tags$a(href="https://cloud.genepattern.org/gp/module/doc/urn:lsid:broad.mit.edu:cancer.software.genepattern.module.analysis:00185:2", "PreviewFCS")),
                                                        
                                                 ),
                                                 column(9,
                                                        p("Once submitted and processed, click on the download button to get your results"),
                                                        p(em("Be patient, this process can take some time")),
                                                        uiOutput("fcspreviewresult")
                                                        
                                                        
                                                 ))),
                                      
                                      tabPanel("FCS Data Conversions",
                                               h3("Module for Data format conversions"),
                                               br(),
                                               h5(strong("Description:")),
                                               p("Allows CSV-FCS format conversions of Flow Cytometry Data."),
                                               hr(),
                                               fluidRow(
                                                 #pongo un conditionalPanel para que según que Tabpanel esté seleccionada, aparezcan unos parámetros u otros al lado izquierdo con todos los botones interactivos
                                                 conditionalPanel(
                                                   condition = "input.conversion=='CsvToFCS'",
                                                   column(3, #lado izquierdo 
                                                          
                                                          h5("Parameters:"),
                                                          fileInput('csvfile_input', strong('Choose csv file:'), multiple = FALSE,  
                                                                    accept = c('text/csv', '.csv')),
                                                          br(),
                                                          actionButton("go_CSVtoFCS", "Convert!"),
                                                          br(),
                                                          br(),
                                                          p("You can download a sample CSV file:", tags$a(href="Prueba.csv", "Here", download=NA, target="_blank") ),
                                                          hr(),
                                                          div(style = "margin-top: 30px; width: 200px; ", HTML("Based on an implementation of GenePattern 2.0 Nature Genetics 38 no. 5 (2006): pp500-501 Google Scholar | Endnote | RIS")),
                                                          div(style = "margin-top: 10px; ", 
                                                              tags$a(href="https://www.genepattern.org/flow-cytometry-data-preprocessing", "Genepattern Suite"))
                                                   )
                                                 ),
                                                 conditionalPanel(
                                                   condition = "input.conversion=='FCStoCsv'",
                                                   column(3, #lado izquierdo 
                                                          
                                                          h5("Parameters:"),
                                                          fileInput('FCSfile_input_2convrt', strong('Choose fcs file:'), multiple = FALSE,  
                                                                    accept = c('text/fcs', '.fcs')),
                                                          br(),
                                                          actionButton("go_FCStoCSV", "Convert!"),
                                                          hr(),
                                                          div(style = "margin-top: 30px; width: 200px; ", HTML("Based on an implementation of GenePattern 2.0 Nature Genetics 38 no. 5 (2006): pp500-501 Google Scholar | Endnote | RIS")),
                                                          div(style = "margin-top: 10px; ", 
                                                              tags$a(href="https://www.genepattern.org/flow-cytometry-data-preprocessing", "Genepattern Suite"))
                                                   )),
                                                 
                                                 column(9,
                                                        tabsetPanel(type = "pills", id="conversion",
                                                                    tabPanel("CsvToFCS",
                                                                             h3("Module for CsvToFcs"),
                                                                             br(),
                                                                             h5(strong("Description: ")),
                                                                             p("Converts Flow Cytometry data in a comma-separated values (CSV) file to a Flow Cytometry Standard (FCS) file."),
                                                                             br(),
                                                                             p("Once submitted and processed, click on the download button to get your results"),
                                                                             p(em("Be patient, this process can take some time")),
                                                                             #uiOutput("CSVtoFCSresult")
                                                                             
                                                                             downloadButton("CSVtoFCSresult", "Download your file")
                                                                             
                                                                    ),
                                                                    tabPanel("FCStoCsv",
                                                                             
                                                                             h3("Module for FCStoCsv"),
                                                                             br(),
                                                                             h5(strong("Description: ")),
                                                                             p("Converts a Flow Cytometry Standard (FCS) file to a comma-separated values (CSV) file."),
                                                                             br(),
                                                                             p("Once submitted and processed, click on the download button to get your results"),
                                                                             p(em("Be patient, this process can take some time")),
                                                                             uiOutput("FCStoCSVresult")
                                                                             
                                                                    ))        
                                                 ))) 
                                      
                                      #######Toda esta parte comentada iría enfocada a un desarrollo futuro del apartado de preprocesado metiendo más módulos de genepattern
                                      #Dejo aquí la estructura hecha
                                      
                                      #             tabPanel("FCS keywords manipulation",
                                      #                      h3("Module for FCS keywords manipulation"),
                                      #                      br(),
                                      #                      h5(strong("Description:")),
                                      #                      p("Includes several modules for FCS keywords manipulation "),
                                      #                      hr(),
                                      #                      fluidRow(
                                      #                        
                                      #                        
                                      #                        column(3, #lado izquierdo con todos los botones interactivos
                                      #                               #style = "background-color:#F6f6fb;",
                                      #                               h5("Parameters:"),
                                      #                               fileInput('previewFCSfile', strong('Choose fcs file:'), multiple = FALSE, #de momento que el archivo sea único, en una mejora se podría mirar para meter varios 
                                      #                                         accept = c('text/fcs', '.fcs')),
                                      #                               hr(),
                                      #                              
                                      #                               hr(),
                                      #                               div(style = "margin-top: 30px; width: 200px; ", HTML("Based on an implementation of GenePattern 2.0 Nature Genetics 38 no. 5 (2006): pp500-501 Google Scholar | Endnote | RIS")),
                                      #                               div(style = "margin-top: 10px; ", 
                                      #                                   tags$a(href="https://cloud.genepattern.org/gp/module/doc/urn:lsid:broad.mit.edu:cancer.software.genepattern.module.analysis:00185:2", "PreviewFCS"))
                                      #                        ),
                                      #                        column(9,
                                      #                               dashboardPage(
                                      #                                 skin = "blue",
                                      #                                 dashboardHeader(disable = TRUE),
                                      #                                 dashboardSidebar( width = "0px"),
                                      #                                 dashboardBody(
                                      #                                   #Módulo DeIdentifyFCS
                                      #                                   box(title = span ("DeIdentifyFCS", style="color:white"),
                                      #                                       
                                      #                                       status = "primary",
                                      #                                       solidHeader = TRUE,
                                      #                                       h5(strong("Description:")),
                                      #                                       p("DeIdentifyFCS an FCS data file; remove keywords from a list or matching a regular expression; useful to anonymize FCS data files and/or to remove specific (e.g., clinical) information."),
                                      #                                       id= "DeIdentifyFCS_module",
                                      #                                       collapsible=TRUE,
                                      #                                       collapsed = TRUE,
                                      #                                       p("esto es una prueba")
                                      #                                       
                                      #                                   ),
                                      #                                   #Módulo ExtractFCSKeywords
                                      #                                   box(title = span ("ExtractFCSKeywords", style="color:white"),
                                      #                                       
                                      #                                       status = "primary",
                                      #                                       solidHeader = TRUE,
                                      #                                       h5(strong("Description:")),
                                      #                                       p("Extracts keyword(s) value(s) from a Flow Cytometry Standard (FCS) file."),
                                      #                                       id= "ExtractFCSKeywords_module",
                                      #                                       collapsible=TRUE,
                                      #                                       collapsed = TRUE,
                                      #                                       p("esto es una prueba")
                                      #                                       
                                      #                                   ),
                                      #                                   #Módulo SetFCSKeywords
                                      #                                   box(title = span ("SetFCSKeywords", style="color:white"),
                                      #                                       
                                      #                                       status = "primary",
                                      #                                       solidHeader = TRUE,
                                      #                                       h5(strong("Description:")),
                                      #                                       p("Sets keyword/value(s) in a Flow Cytometry Standard (FCS) file."),
                                      #                                       id= "SetFCSKeywords_module",
                                      #                                       collapsible=TRUE,
                                      #                                       collapsed = TRUE,
                                      #                                       p("esto es una prueba")
                                      #                                       
                                      #                                   ),
                                      #                              
                                      #                                 
                                      #                                  
                                      #                                 
                                      #                                 ))))),
                                      #               tabPanel("FCS dataset manipulation", #completar
                                      #                        h3("Module for FCS dataset manipulation"),
                                      #                        br(),
                                      #                        h5(strong("Description:")),
                                      #                        p("Includes several modules for FCS Dataset manipulation "),
                                      #                        hr(),
                                      #                        fluidRow(
                                      #                          
                                      
                                      #                          column(3, #lado izquierdo con todos los botones interactivos
                                      #                                 #style = "background-color:#F6f6fb;",
                                      #                                 h5("Parameters:"),
                                      #                                 fileInput('previewFCSfile', strong('Choose fcs file:'), multiple = FALSE, #de momento que el archivo sea único, en una mejora se podría mirar para meter varios 
                                      #                                           accept = c('text/fcs', '.fcs')),
                                      #                                 hr(),
                                      #                                 #MEJORA: poner un botón 
                                      #                                 #en genepattern dejan opción de elegir como formato de salida HTML o XML, yo voy a tratar que sea HTML proyectado dentro de la web, añadir la otra opción sería una mejora a posteriori
                                      #                                 hr(),
                                      #                                 div(style = "margin-top: 30px; width: 200px; ", HTML("Based on an implementation of GenePattern 2.0 Nature Genetics 38 no. 5 (2006): pp500-501 Google Scholar | Endnote | RIS")),
                                      #                                 div(style = "margin-top: 10px; ", 
                                      #                                     tags$a(href="https://cloud.genepattern.org/gp/module/doc/urn:lsid:broad.mit.edu:cancer.software.genepattern.module.analysis:00185:2", "PreviewFCS"))
                                      #                          ),
                                      #                          column(9,
                                      #                              dashboardPage(
                                      #                                skin = "blue",
                                      #                                dashboardHeader(disable = TRUE),
                                      #                                dashboardSidebar( width = "0px"),
                                      #                                dashboardBody(
                                      #                                  #Módulo AddFCSEventIndex
                                      #                                box(title = span ("AddFCSEventIndex", style="color:white"),
                                      #                                
                                      #                                status = "primary",
                                      #                                solidHeader = TRUE,
                                      #                                h5(strong("Description:")),
                                      #                                p("Adds indexes to events in a Flow Cytometry Standard (FCS) data file."),
                                      #                                id= "AddFCSEventIndex_module",
                                      #                                collapsible=TRUE,
                                      #                                collapsed = TRUE,
                                      #                                p("esto es una prueba")
                                      #                                  
                                      #                                ),
                                      #                                #Módulo AddFCSParameter
                                      #                                box(title = span ("AddFCSParameter", style="color:white"),
                                      #                                    
                                      #                                    status = "primary",
                                      #                                    solidHeader = TRUE,
                                      #                                    h5(strong("Description:")),
                                      #                                    p("Adds parameters and their values to a Flow Cytometry Standard (FCS) data file."),
                                      #                                    id= "AddFCSParameter_module",
                                      #                                    collapsible=TRUE,
                                      #                                    collapsed = TRUE,
                                      #                                    p("esto es una prueba")
                                      #                                    
                                      #                                ),
                                      #                                #Módulo AddNoiseToFCS
                                      #                                box(title = span ("AddNoiseToFCS", style="color:white"),
                                      #                                    
                                      #                                    status = "primary",
                                      #                                    solidHeader = TRUE,
                                      #                                    h5(strong("Description:")),
                                      #                                    p("Add noise to specified parameters in an FCS data file."),
                                      #                                    id= "AddNoiseToFCS_module",
                                      #                                    collapsible=TRUE,
                                      #                                    collapsed = TRUE,
                                      #                                    p("esto es una prueba")
                                      #                                    
                                      #                                ),
                                      #                                #Módulo ExtractFCSDataset
                                      #                                box(title = span ("ExtractFCSDataset", style="color:white"),
                                      #                                    
                                      #                                    status = "primary",
                                      #                                    solidHeader = TRUE,
                                      #                                    h5(strong("Description:")),
                                      #                                    p("Extracts one or more Flow Cytometry Standard (FCS) data sets from an FCS data file."),
                                      #                                    id= "ExtractFCSDataset_module",
                                      #                                    collapsible=TRUE,
                                      #                                    collapsed = TRUE,
                                      #                                    p("esto es una prueba")
                                      #                                    
                                      #                                ),
                                      #                                #Módulo ExtractFCSParameters
                                      #                                box(title = span ("ExtractFCSParameters", style="color:white"),
                                      #                                    
                                      #                                    status = "primary",
                                      #                                   solidHeader = TRUE,
                                      #                                    h5(strong("Description:")),
                                      #                                    p("Extracts specified parameters from a Flow Cytometry Standard (FCS) file."),
                                      #                                    id= "ExtractFCSParameters_module",
                                      #                                    collapsible=TRUE,
                                      #                                    collapsed = TRUE,
                                      #                                    p("esto es una prueba")
                                      #                                    
                                      #                                ),
                                      #                                #Módulo MergeFCSDataFiles
                                      #                                box(title = span ("MergeFCSDataFiles", style="color:white"),
                                      #                                    
                                      #                                    status = "primary",
                                      #                                    solidHeader = TRUE,
                                      #                                    h5(strong("Description:")),
                                      #                                    p("Merge multiple Flow Cytometry Standard (FCS) data files into a single FCS dataset; includes sub-sampling option."),
                                      #                                    id= "MergeFCSDataFiles_module",
                                      #                                    collapsible=TRUE,
                                      #                                    collapsed = TRUE,
                                      #                                    p("esto es una prueba")
                                      #                                    
                                      #                                ),
                                      #                                #Módulo RemoveSaturatedFCSEvents
                                      #                                box(title = span ("RemoveSaturatedFCSEvents", style="color:white"),
                                      #                                    
                                      #                                    status = "primary",
                                      #                                    solidHeader = TRUE,
                                      #                                    h5(strong("Description:")),
                                      #                                    p("Remove saturated events from an FCS data file."),
                                      #                                    id= "RemoveSaturatedFCSEvents_module",
                                      #                                    collapsible=TRUE,
                                      #                                    collapsed = TRUE,
                                      #                                    p("esto es una prueba")
                                      #                                    
                                      #                                )
                                      #                              )
                                      #                                 ))
                                      
                                      #                          ))
                                      
                           ),
                           #####
                           tabPanel("Quality Assessment", #esta va a ser la página de procesado de calidad
                                    
                                    h3("Module for Data Quality Assessment"),
                                    br(),
                                    h5(strong("Description:")),
                                    p("Perform quality control of a single panel from cytometry data"),
                                    hr(),
                                    fluidRow(
                                      column(3, #lado izquierdo con todos los botones interactivos
                                             
                                             fileInput('fcsFiles', strong('Choose fcs file(s):'), multiple = TRUE, 
                                                       accept = c('text/fcs', '.fcs')),
                                             
                                             actionButton("goButton", "Submit!"),
                                             hr(),
                                             downloadButton('downloadMarkers', 'Download markers table'),
                                             br(),
                                             downloadButton('downloadFCS', 'Download new FCS files'),
                                             hr(),
                                             
                                             ## sample limits: 50
                                             uiOutput("sample_select"), 
                                             #aparecerán checkbox con las muestras una vez leido el archivo
                                             
                                             lapply(1:50, function(i) { #aplica la función a los elementos de una lista que vayan de 1-50
                                               uiOutput(paste0('timeSlider', i))
                                             }),
                                             
                                             hr(),
                                             uiOutput("marker_select"),
                                             
                                             hr(),
                                             div(style = "margin-top: 30px; width: 200px; ", HTML("Quality Assessment is based on flowiQC, Shiny app developed by Monaco G & Chen H, public code can be found:")),
                                             div(style = "margin-top: 10px; ", 
                                                 tags$a(href="https://github.com/SIgNBioinfo/flowiQC_shinyAPP", "Github Repository"))
                                      ),
                                      column(9,
                                             tabsetPanel(type = "pills", #crea los submenús de la página
                                                         
                                                         tabPanel("Cell numbers", 
                                                                  hr(),
                                                                  htmlOutput("cnplot")), #contenido de tipo html
                                                         
                                                         tabPanel("Time flow", fluidPage(
                                                           hr(),
                                                           htmlOutput("tfplot"),
                                                           hr(),
                                                           
                                                           fluidRow(
                                                             column(4, offset = 1,
                                                                    numericInput("tf_binSize", "Bin size:", value = NA)
                                                             ),
                                                             column(4, 
                                                                    numericInput("tf_varCut", "Variation cut:", value = 1)
                                                             ) 
                                                           ),
                                                           
                                                           textOutput("tf_text") #salida de texto interactiva
                                                         )),
                                                         
                                                         tabPanel("Timeline", fluidPage(
                                                           tags$style(type="text/css",
                                                                      ".shiny-output-error { visibility: hidden; }",
                                                                      ".shiny-output-error:before { visibility: hidden; }"
                                                           ),
                                                           hr(),
                                                           uiOutput("tl_sample_choose"), #va a ser dependiente del input
                                                           
                                                           hr(),
                                                           h4("Timeline plot:"),
                                                           htmlOutput("tlplot"),
                                                           
                                                           hr(),
                                                           h4("Expression table plot:"),
                                                           plotOutput("tabplot1"),
                                                           
                                                           hr(),
                                                           fluidRow(
                                                             column(4, offset = 1,
                                                                    numericInput("tl_binSize", "Bin size:", value = NA)
                                                             ),
                                                             column(4,
                                                                    numericInput("tl_varCut", "Variation cut:", value = 1)
                                                             ) 
                                                           ),
                                                           textOutput("tl_text")
                                                         )),
                                                         
                                                         tabPanel("Margin Events", 
                                                                  fluidPage(
                                                                    hr(),
                                                                    fluidRow(
                                                                      column(4, offset = 1,
                                                                             selectInput("side", "Select checking side:",
                                                                                         choices = c("both", "upper", "lower"), 
                                                                                         selected = "both")
                                                                      ),
                                                                      column(4, 
                                                                             numericInput("tol", "Tolerance value:", -.Machine$double.eps)
                                                                      ) 
                                                                    ),
                                                                    hr(),
                                                                    plotOutput("meplot"),
                                                                    hr(),
                                                                    
                                                                    h4("Time Distribution of Margin Events:"),
                                                                    fluidRow(
                                                                      column(5, offset = 1, uiOutput("me_sample_choose") ),
                                                                      column(3, uiOutput("me_channel_choose") )
                                                                    ),
                                                                    
                                                                    hr(),
                                                                    htmlOutput("upMeTimePlot"),
                                                                    htmlOutput("lowMeTimePlot"),
                                                                    br(),
                                                                    br(),
                                                                    textOutput("meTime_text")
                                                                    
                                                                  )),
                                                         
                                                         tabPanel("QA score", fluidPage(
                                                           hr(),
                                                           uiOutput("score_sample_choose"),
                                                           
                                                           h4("QA score summary:"),
                                                           plotOutput("scoreplot"),
                                                           fluidRow(
                                                             column(width = 3,
                                                                    numericInput("score_nrbins", "Row bins:", value = 100)
                                                             ),
                                                             column(width = 3, offset = 1, 
                                                                    numericInput("scoreThres", "Threshold score:", value = 3, step = 0.1)
                                                             ),
                                                             column(width = 4, offset = 1, 
                                                                    uiOutput("sort_ID")
                                                             ) 
                                                           )
                                                         )),
                                                         
                                                         tabPanel("Summary",
                                                                  fluidPage(
                                                                    verticalLayout(
                                                                      hr(),
                                                                      h4("Cell Number check:"),
                                                                      htmlOutput("cntable"),
                                                                      hr(),
                                                                      h4("Margin Events check:"),
                                                                      htmlOutput("metable"),
                                                                      hr(),
                                                                      h4("Time flow check:"),
                                                                      plotOutput("s_tfplot"),
                                                                      hr(),
                                                                      h4("Timeline check:"),
                                                                      plotOutput("s_tlplot")
                                                                    )
                                                                  ))
                                             )
                                      )
                                    )),
                           
                           #####
                           navbarMenu("Gating & Clustering", #Menú de gating y clústering
                                      tabPanel("Gating",
                                               h3("Module for Data visualization and Manual Gating"),
                                               br(),
                                               h5(strong("Description:")),
                                               p("Allows compensation of an FCS file, FSC/SSC visualization and carrying out Manual gating over the data"),
                                               hr(),
                                               fluidRow(
                                                 column(3, #lado izquierdo con todos los botones interactivos
                                                        h5("Parameters:"),
                                                        fileInput('gatingFCSfile', strong('Choose fcs file:'), multiple = FALSE, #de momento que el archivo sea único, en una mejora se podría mirar para meter varios 
                                                                  accept = c('text/fcs', '.fcs')),
                                                        actionButton("gating1_Button", "Submit!"),
                                                        hr(),
                                                        checkboxInput("check_compensate1","To compensate FCS data please provide a compensation matrix , if compensation matrix is incluided in file ignore this button", value=FALSE),
                                                        conditionalPanel(
                                                          condition= "input.check_compensate1 == 1",
                                                          fileInput('compensate1FCSfile', strong('Choose compensation matrix:'), multiple = FALSE, #de momento que el archivo sea único, en una mejora se podría mirar para meter varios 
                                                                    accept = c('text/fcs', '.fcs')) 
                                                        ),
                                                        
                                                        
                                                        
                                                        hr(),
                                                        div(style = "margin-top: 30px; width: 200px; ", HTML("Gating is based on CytoTree package: Dai Y (2021). CytoTree: A Toolkit for Flow And Mass Cytometry Data. ")),
                                                        div(style = "margin-top: 10px; ", 
                                                            tags$a(href="https://github.com/JhuangLab/CytoTree", "Github Repository"))
                                                 ),
                                                 column(9,
                                                        fluidRow(h5("Here you can observe your raw data on an FSC/SSC plot"),
                                                                 plotOutput("FCSvsSSC_plot"),
                                                                 downloadButton("gating_graph1", "Download plot")
                                                                
                                                                 
                                                        ),
                                                        hr(),
                                                        tags$script("$(document).on('shiny:connected', function(event) { #mejorar la resolución del gráfico: https://stackoverflow.com/questions/45642283/how-to-save-png-image-of-shiny-plot-so-it-matches-the-dimensions-on-my-screen
                                                        
                                                          var myWidth = $(window).width();
                                                          Shiny.onInputChange('shiny_width',myWidth)

                                                                    });"),
                                                        
                                                        tags$script("$(document).on('shiny:connected', function(event) {
                                                        var myHeight = $(window).height();
                                                        Shiny.onInputChange('shiny_height',myHeight)

                                                        });"),
                                                        
                                                        fluidRow(h5("Please, provide upper and lower gate values to get a subsample of your data."),
                                                                 p("After clicking on “Gate Events” an updated FSC/SSC plot will appear. This process can take some time."),
                                                                 column(width=3, 
                                                                        p("Upper Gate"),
                                                                        numericInput("Upper_SSC", "SSC:", 0), #puede añadirse un campo indicando valor máximo o mínimo que se puede meter, esto sería una mejora
                                                                        numericInput("Upper_FSC", "FSC:", 0),
                                                                        
                                                                 ),
                                                                 column(width=1),
                                                                 
                                                                 column(width=3, 
                                                                        p("Lower Gate"),
                                                                        numericInput("Lower_SSC", "SSC:", 0),
                                                                        numericInput("Lower_FSC", "FSC:", 0)
                                                                        
                                                                 ),
                                                                 column(width=1,
                                                                        br(),
                                                                        actionButton("gating2_Button", "Gate Events!")),
                                                                 
                                                                 
                                                                 plotOutput("FCSvsSSC_gated_plot"),
                                                                
                                                                 ),
                                                        
                                                        br(),
                                                        br(),
                                                        fluidRow(br(), #meto muchos espacios porque se me solapaban los gráficos
                                                                 br(),
                                                                 br(),
                                                                 br(),
                                                                 br(),
                                                                 br(),
                                                                 br(),
                                                                 downloadButton("gating_graph2", "Download plot"),
                                                                 hr(),
                                                                 h5("Plot your gated events"),
                                                                 p ("Here you can set xaxis and yaxis values :"),
                                                                 uiOutput("gating_xaxis"),
                                                                 uiOutput("gating_yaxis"),
                                                                 plotlyOutput("gated_interactive_plot")
                                                        )
                                                        
                                                 )
                                                 
                                                 
                                               )),
                                      tabPanel("Clustering",
                                               h3("Module for Flow Cytometry Clustering"),
                                               br(),
                                               h5(strong("Description:")),
                                               p("Allows Clustering FCS data using 6 clustering algorythms "),
                                               hr(),
                                               fluidRow(
                                                 column(3, #lado izquierdo con todos los botones interactivos
                                                        h5("Parameters:"),
                                                        selectInput("algorythm", "Please choose a clustering algorythm to show more options", 
                                                                    c("","SOM", "KMEANS","CLARA", "PHENOGRAPH", "MCLUST", "HCLUST"),selected=NULL,multiple = FALSE),
                                                        fileInput('clusteringFile', strong('Choose fcs file:'), multiple = FALSE, #de momento que el archivo sea único, en una mejora se podría mirar para meter varios 
                                                                  accept = c('text/fcs', '.fcs')),
                                                        actionButton("clustering1_Button", "Submit!"),
                                                        hr(),
                                                        #Uso un conditional panel para proporcionar la matriz de compensación
                                                        checkboxInput("check_compensate2","To compensate FCS data please provide a compensation matrix , if compensation matrix is incluided in file ignore this button", value=FALSE),
                                                        conditionalPanel(
                                                          condition= "input.check_compensate2 == 1",
                                                          fileInput('compensate2FCSfile', strong('Choose compensation matrix:'), multiple = FALSE, #de momento que el archivo sea único, en una mejora se podría mirar para meter varios 
                                                                    accept = c('text/fcs', '.fcs')) 
                                                        ),
                                                        
                                                        
                                                        hr(),
                                                        div(style = "margin-top: 30px; width: 200px; ", HTML("Clustering is based on CytoTree package: Dai Y (2021). CytoTree: A Toolkit for Flow And Mass Cytometry Data. ")),
                                                        div(style = "margin-top: 10px; ", 
                                                            tags$a(href="https://github.com/JhuangLab/CytoTree", "Github Repository"))
                                                 ),
                                                 column(9,
                                                        conditionalPanel(
                                                          condition= "input.algorythm=='' ",
                                                          fluidRow( h5(strong("Flow Cytometry Clustering")),
                                                                    p("On the parameters menu, on the left-side part of the page you can select up to 6 different clustering algorithms to apply to your data:"),
                                                                    h6("SOM: Self Organizing Maps"),
                                                                    h6("K-MEANS"),
                                                                    h6("CLARA :Clustering Large Applications"),
                                                                    h6("PHENOGRAPH"),
                                                                    h6("HCLUST:Hierarchical Clustering"),
                                                                    h6("MCLUST: Model-Based Clustering"),
                                                                    
                                                                    p("Once the algorithm is performed , four-dimensional reduction methods are applied to each cluster, including PCA, tSNE, diffusion maps, and UMAP, so on last instance you will get a 2D-visualization of your data:"),
                                                                    br(),
                                                                    tags$img(src="Ejemplo.png", width="937px", height="400px")
                                                          ) 
                                                        ),
                                                        conditionalPanel(
                                                          condition= "input.algorythm == 'SOM'",
                                                          fluidRow(
                                                            h5(strong("SOM (Self Organizing Maps) algorithm")),
                                                            p("The Self-Organizing Map is one of the most popular neural network models, it is based on unsupervised learning. You can submitt your FCS file and select your clustering parameters. Results will be visualized on a 2D plot"),
                                                            p("If you wish to learn more about SOM algorithm on flow cytometry click:", tags$a(href="https://ytdai.github.io/CytoTree/ti.html", "here")),
                                                            br(),
                                                            br(),
                                                            p(strong("Clustering parameters:")),
                                                            
                                                            numericInput("som_number", "Number of clusters:", 50),
                                                            p("For > 100,000 events is recommended to carry out downsampling. You can set percentage of downsampled cells (1= 100% of cells, 0.5= 50% of cells..)"),
                                                            numericInput("som_downsampling", "Downsampling percentage:", 1, min=0.000001, max=1),
                                                            
                                                            p ("Here you can set xaxis and yaxis values :"),
                                                            uiOutput("som_xaxis"),
                                                            uiOutput("som_yaxis"),
                                                            hr(),
                                                            plotlyOutput("SOM_plot")) 
                                                        ),
                                                        conditionalPanel(
                                                          condition = "input.algorythm == 'KMEANS'",
                                                          fluidRow(
                                                            
                                                            h5(strong("K-MEANS algorithm")),
                                                            p("K-Means is a widely used non supervised clustering algorithm. You can submitt your FCS file and select your clustering parameters. Results will be visualized on a 2D plot"),
                                                            p("If you wish to learn more about K-MEANS algorithm on flow cytometry click:", tags$a(href="https://ytdai.github.io/CytoTree/ti.html", "here")),
                                                            br(),
                                                            br(),
                                                            p(strong("Clustering parameters:")),
                                                            
                                                            numericInput("k_number", "Number of clusters:", 50),
                                                            p("For > 100,000 events is recommended to carry out downsampling. You can set percentage of downsampled cells (1= 100% of cells, 0.5= 50% of cells..)"),
                                                            numericInput("k_downsampling", "Downsampling percentage:", 1, min=0.000001, max=1),
                                                            
                                                            p ("Here you can set xaxis and yaxis values :"),
                                                            uiOutput("kmeans_xaxis"),
                                                            uiOutput("kmeans_yaxis"),
                                                            hr(),
                                                            
                                                            plotlyOutput("KMEANS_plot")
                                                          )),
                                                        conditionalPanel(
                                                          condition = "input.algorythm == 'CLARA'",
                                                          fluidRow(
                                                            
                                                            h5(strong("CLARA (Clustering Large Applications) algorithm ")),
                                                            p("CLARA is an extension to the PAM (Partitioning Around Medoids) clustering method. You can submitt your FCS file and select your clustering parameters. Results will be visualized on a 2D plot"),
                                                            p("If you wish to learn more about CLARA algorithm on flow cytometry click:", tags$a(href="https://ytdai.github.io/CytoTree/ti.html", "here")),
                                                            br(),
                                                            br(),
                                                            p(strong("Clustering parameters:")),
                                                            
                                                            numericInput("clara_number", "Number of clusters:", 50),
                                                            p("For > 100,000 events is recommended to carry out downsampling. You can set percentage of downsampled cells (1= 100% of cells, 0.5= 50% of cells..)"),
                                                            numericInput("clara_downsampling", "Downsampling percentage:", 1, min=0.000001, max=1),
                                                            
                                                            p ("Here you can set xaxis and yaxis values :"),
                                                            uiOutput("clara_xaxis"),
                                                            uiOutput("clara_yaxis"),
                                                            hr(),
                                                            
                                                            plotlyOutput("CLARA_plot")
                                                          )),
                                                        conditionalPanel(
                                                          condition = "input.algorythm == 'PHENOGRAPH'",
                                                          fluidRow(
                                                            
                                                            h5(strong("PHENOGRAPH")),
                                                            p("PhenoGraph is a clustering method designed for high-dimensional single-cell data. You can submitt your FCS file and select your clustering parameters. Results will be visualized on a 2D plot"),
                                                            p("This algorithm is not recommended for data with more than 10,000 events. Note that this process can take some time"),
                                                            p("If you wish to learn more about PhenoGraph algorithm on flow cytometry click:", tags$a(href="https://ytdai.github.io/CytoTree/ti.html", "here")),
                                                            br(),
                                                            br(),
                                                            p(strong("Clustering parameters:")),
                                                            #con el algoritmo de phenograph no se pueden modificar el número de clústers
                                                            
                                                            p("For > 100,000 events is recommended to carry out downsampling. You can set percentage of downsampled cells (1= 100% of cells, 0.5= 50% of cells..)"),
                                                            numericInput("pheno_downsampling", "Downsampling percentage:", 1, min=0.000001, max=1),
                                                            
                                                            p ("Here you can set xaxis and yaxis values :"),
                                                            uiOutput("pheno_xaxis"),
                                                            uiOutput("pheno_yaxis"),
                                                            hr(),
                                                            
                                                            plotlyOutput("PHENO_plot")
                                                          )),
                                                        conditionalPanel(
                                                          condition = "input.algorythm == 'HCLUST'",
                                                          fluidRow(
                                                            
                                                            h5(strong("HCLUST:Hierarchical Clustering ")),
                                                            p("You can submitt your FCS file and select your clustering parameters. Results will be visualized on a 2D plot"),
                                                            p("This algorithm is not recommended for data with more than 50,000 events. Note that this process can take some time"),
                                                            p("If you wish to learn more about HCLUST algorithm on flow cytometry click:", tags$a(href="https://ytdai.github.io/CytoTree/ti.html", "here")),
                                                            br(),
                                                            br(),
                                                            p(strong("Clustering parameters:")),
                                                            
                                                            numericInput("h_number", "Number of clusters:", 50),
                                                            p("For > 100,000 events is recommended to carry out downsampling. You can set percentage of downsampled cells (1= 100% of cells, 0.5= 50% of cells..)"),
                                                            numericInput("h_downsampling", "Downsampling percentage:", 1, min=0.000001, max=1),
                                                            
                                                            p ("Here you can set xaxis and yaxis values :"),
                                                            uiOutput("hclust_xaxis"),
                                                            uiOutput("hclust_yaxis"),
                                                            hr(),
                                                            
                                                            plotlyOutput("HCLUST_plot")
                                                          )
                                                        ),
                                                        conditionalPanel(
                                                          condition = "input.algorythm == 'MCLUST'",
                                                          fluidRow(
                                                            
                                                            h5(strong("MCLUST: Model-Based Clustering")),
                                                            p("You can submitt your FCS file and select your clustering parameters. Results will be visualized on a 2D plot"),
                                                            p("This algorithm is not recommended for data with more than 10,000 events. Note that the process can take some time"),
                                                            p("If you wish to learn more about MCLUST algorithm on flow cytometry click:", tags$a(href="https://ytdai.github.io/CytoTree/ti.html", "here")),
                                                            br(),
                                                            br(),
                                                            p(strong("Clustering parameters:")),
                                                            
                                                            numericInput("m_number", "Number of clusters:", 50),
                                                            p("For > 100,000 events is recommended to carry out downsampling. You can set percentage of downsampled cells (1= 100% of cells, 0.5= 50% of cells..)"),
                                                            numericInput("m_downsampling", "Downsampling percentage:", 1, min=0.000001, max=1),
                                                            sliderInput("m_perplexity", "Perplexity:",  min=1, max=50, 2 ),
                                                            
                                                            
                                                            p ("Here you can set xaxis and yaxis values :"),
                                                            uiOutput("mclust_xaxis"),
                                                            uiOutput("mclust_yaxis"),
                                                            hr(),
                                                            
                                                            plotlyOutput("MCLUST_plot")
                                                          )
                                                        )
                                                        
                                                        
                                                        
                                                 )
                                               )
                                      )
                                      
                           ))
               
)






################


options(shiny.maxRequestSize=900*1024^2) #esta línea de código permite subir archivos hasta esa limitación de tamaño
###Server (es la parte que procesa los datos)
server<- function(input,output) {
  
  
  #el input es reactivo, es decir, cada vez que cambie $input, se reejecutará
  
  ###PREPROCESSING
  #PreviewFCS 
  observeEvent(input$go_fcspreview,
               {if (is.null(input$go_fcspreview)) return(NULL)
                 show_modal_spinner(
                   spin = "double-bounce",
                   color = "#112446",
                   text = "Please wait...",
                 )
                 FCSfile<-input$previewFCSfile$name
                 FCSfile_path<-input$previewFCSfile$datapath
                 
                 previewfcs_result <- py$PreviewFCS_function(FCSfile, FCSfile_path) #desde aquí invoco la función de python creada por mi y la aplico sobre el archivo que toma como input la interfaz de shiny
                 output$fcspreviewresult=renderUI({
                   actionButton(inputId = "fcspreviewresult",
                                label= "Download your results",
                                icon= icon("download"),
                                onclick= paste( "window.open(","'", previewfcs_result,"',", "'_blank')")) #El resultado del procesado de genepattern devuelve un link de descarga automática del zip con los resultados
                 }
                 
                 )
                 remove_modal_spinner()
               })
  
  #FCStoCSV
  observeEvent(input$go_FCStoCSV,
               {if (is.null(input$go_FCStoCSV)) return(NULL)
                 show_modal_spinner(
                   spin = "double-bounce",
                   color = "#112446",
                   text = "Please wait...",
                 )
                 FCSfile<-input$FCSfile_input_2convrt$name
                 FCSfile_path<-input$FCSfile_input_2convrt$datapath
                 csv_result <- py$FcsToCsv_function(FCSfile, FCSfile_path)
                 
                 
                 
                 
                 output$FCStoCSVresult=renderUI({
                   actionButton(inputId = "FCStoCSVresult",
                                label= "Download your results",
                                icon= icon("download"),
                                onclick= paste( "window.open(","'", csv_result,"',", "'_blank')"))
                 }
                 
                 )
                 remove_modal_spinner()
               })
  
  #CSVtoFCS
  observeEvent(input$go_CSVtoFCS,
               {if (is.null(input$go_CSVtoFCS)) return(NULL)
                 show_modal_spinner(
                   spin = "double-bounce",
                   color = "#112446",
                   text = "Please wait...",
                 )
                 CSVfile<-input$csvfile_input$name
                 CSVfile_path<-input$csvfile_input$datapath
                 #print(CSVfile_path)
                 prueba <-system(paste0("java -jar csv2fcs.jar -InputFile:", CSVfile_path)) 
      
                 
                 FCSfile<- gsub(".csv", ".fcs", CSVfile) #nombre del nuevo fichero
                 FCSfile_path<- gsub(".csv", ".fcs", CSVfile_path) #ruta al nuevo fichero
                 output$CSVtoFCSresult <- downloadHandler(
                   filename = function(){
                     
                     paste(FCSfile)
                   },
                   content=function(file){
                     #print(file)
                     
                     #print(FCSfile_path)
                     file.copy(FCSfile_path, file)
                     
                   }
                 )
                 #)
                 remove_modal_spinner()
               })
  
  
  
  
  ###QUALITY CONTROL
  #Casi todo el código de este apartado se ha cogido de FlowiQC, de su repositorio de GitHub , realizo anotaciones y algunas modificaciones
  ## Lectura del archivo FCS
  observeEvent(input$goButton, { 
    if (is.null(input$goButton)) return (NULL) #mientras el valor inicial del botón sea 0 (es decir no se ha pulsado nada aún)no va a devolver nada
    isolate({fcsFiles <- input$fcsFiles #dentro de la función reactiva aislamos la lectura del fichero, para que una vez leido lo almacene y no rejecute código aunque cambien otros parámetros de esta expresión
    if (is.null(fcsFiles))
      return(NULL) #cuando no se suba ningún archivo no devuelve nada
    set <- read.flowSet(fcsFiles$datapath) #si hay archivo y se ha dado a submit, lee el archivo FCS con la funcion del paquete flowCore
    sampleNames(set) <- fcsFiles$name})
    ## Lectura de los distintos canales
    channels <- reactive({
      if(is.null(set))
        return(NULL) #es reactivo, si no hay objeto set no habrá resultado en pantalla
      pd <- set[[1]]@parameters@data #si lo he entendido bien se usa para crear un objeto de tipo S4 al que accedemos a sus variables por @
      channels <- pd$name
      return(channels)
    })
    
    ## Obtención de los marcadores
    markerNames <- reactive({ #Aquí generamos una variable con los nombres de los marcadores
      if(is.null(set))
        return(NULL) #de nuevo se hace reactivo y dependiente 
      pd <- set[[1]]@parameters@data
      markers <- paste("<", pd$name, ">:", pd$desc, sep = "")
      return(markers)
    })
    
    output$marker_select <- renderUI({ 
      if(is.null(markerNames())){
        return(NULL) #si no hay nombres de los marcadores, no devuelve nada
      }else{
        checkboxGroupInput('paras', strong('Select markers:'), 
                           markerNames(), selected = markerNames()) #crea un checkbox con los marcadores y por defecto salen todos seleccionados
      }   
    })
    
    channelSelect <- reactive({
      if(is.null(markerNames()))
        return(NULL)
      setdiff(channels()[match(input$paras, markerNames())], c('Time', "time"))
    })
    
    ## Para seleccionar la muestra 
    output$sample_select <- renderUI({
      if(is.null(set)){
        return(NULL)
      }else{
        checkboxGroupInput('samples', strong('Select samples:'), 
                           sampleNames(set), selected = sampleNames(set))
      }   
    })
    
    ## time cut UI -----
    lapply(1:50, function(i) {
      output[[paste0('timeSlider', i)]] <- renderUI({
        if(is.null(set))
          return(NULL)
        if (i <= length(set)){
          x <- set[[i]]
          time <- findTimeChannel(x)
          mint <- min(exprs(x)[, time])
          maxt <- max(exprs(x)[, time])
          sliderInput(paste0('timeCut', i), strong(paste0('Time cut for sample ', i," :")),
                      min = mint, max = maxt, value = c(mint, maxt), step = 1)
        }
      })
    })
    
    ## time threshold get from time cut UI
    timeThres <- reactive({
      if(is.null(set))
        return(NULL)
      timeThres <- list()
      for (i in 1:length(set)){
        sample <- sampleNames(set)[i]
        timeRange <- input[[paste0('timeCut', i)]]
        timeThres[[sample]] <- timeRange
      }
      return(timeThres)
    })
    
    ## time filtered flowset
    fset <- reactive({
      if(is.null(set))
        return(NULL)
      flowList <- list()
      for (i in 1:length(set)){
        y <- set[[i]]
        name <- sampleNames(set)[i]
        time <- findTimeChannel(y)
        params <- parameters(y)
        keyval <- keyword(y)
        sub_exprs <- exprs(y)
        timeRange <- timeThres()[[name]]
        minTime <- timeRange[1]
        maxTime <- timeRange[2]
        okCellid <- sub_exprs[,time] >= minTime & sub_exprs[,time] <= maxTime
        sub_exprs <- sub_exprs[okCellid, ]
        flowList[[name]] <- flowFrame(exprs = sub_exprs, parameters = params, description=keyval)
      }
      flowSet <- as(flowList, "flowSet")
    })
    
    
    ## reactive QC analysis
    fsScore <- reactive({
      if(is.null(set))
        return(NULL)
      flowQA_firstScoreInit(set)})
    
    fcn <- reactive({
      if(is.null(set))
        return(NULL)
      flowQA_cellnum(set)})
    
    fsm <- reactive({
      if(is.null(fset()))
        return(NULL)
      flowQA_marginevents(fset(), side = input$side, tol = input$tol)})
    
    fsm_score <- reactive({
      if(is.null(set))
        return(NULL)
      marginEventsScore(set, parms = channelSelect(),
                        side = input$side, tol = input$tol)
    })
    
    fstf <- reactive({
      if(is.null(set))
        return(NULL)
      flowQA_timeflow(set, binSize = input$tf_binSize)})
    
    fstf_score <- reactive({
      if(is.null(fstf()))
        return(NULL)
      timeFlowScore(set, binSize = fstf()$binSize, 
                    varCut = input$tf_varCut)})
    
    fstf_gvis <- reactive({
      if(is.null(set))
        return(NULL)
      flowS <- set
      binSize <- fstf()$binSize
      mint <- min(fsApply(flowS, function(x){
        time <- findTimeChannel(x)
        min(exprs(x)[, time])}))
      maxt <- max(fsApply(flowS, function(x){
        time <- findTimeChannel(x)
        max(exprs(x)[, time])}))
      nrBins <- floor(max(fsApply(flowS, nrow, use.exprs = TRUE)) / binSize)
      tbins <- seq(mint, maxt, len=nrBins + 1)    # time bins
      
      counts <- fsApply(flowS, function(x){
        time <- findTimeChannel(x)
        xx <- sort(exprs(x)[, time])   # time channel
        tbCounts <- hist(xx, tbins, plot = FALSE)$counts  # number of events per time bin
      })
      tcord <- as.data.frame(t(counts))
      tcord$time <- tbins[-1]
      return(tcord)
    })
    
    fstl <- reactive({
      if(is.null(set))
        return(NULL)
      flowQA_timeline(set, binSize = input$tl_binSize,
                      varCut= input$tl_varCut)})
    
    qaScore <- reactive({
      if(is.null(fstl()))
        return(NULL)
      fsScore <- flowQA_scoreUpdate(fsScore(), fsm_score())
      fsScore <- flowQA_scoreUpdate(fsScore, fstf_score())
      fsScore <- flowQA_scoreUpdate(fsScore, fstl()$tlScore)
      qaScore <- flowQA_scoreSummary(fsScore)
      return(qaScore) })
    
    ## render cell number plot
    output$cnplot <- renderGvis({
      if(is.null(set))
        return(NULL)
      cnframe <- fcn()
      data <- as.data.frame(cnframe[match(input$samples, cnframe$sampleName), ] )
      Sys.sleep(0.3)
      gvisColumnChart(data, 
                      xvar = "sampleName", yvar = "cellNumber",
                      options=list(title="Cell Number for Each Sample",
                                   width = 900, height = 500, vAxis="{minValue: 0}")
      )
    })
    
    output$cntable <- renderGvis({
      if(is.null(set))
        return(NULL)
      cnframe <- fcn()
      data <- as.data.frame(cnframe[match(input$samples, cnframe$sampleName), ] )
      #Sys.sleep(0.3)
      return(gvisTable(data))
    })
    
    ## render margin events plot        
    output$meplot <- renderPlot({
      if(is.null(set))
        return(NULL)
      perc <- fsm()
      perc <- as.matrix(perc[channelSelect(), input$samples])
      col.regions=colorRampPalette(c("white",  "darkblue"))(256)
      print(levelplot(perc*100, scales = list(x = list(rot = 45), y = list(rot = 45)),
                      xlab="", ylab="", main="Percentage of margin events",
                      col.regions=col.regions))
    })
    
    output$metable <- renderGvis({
      if(is.null(set))
        return(NULL)
      perc <- fsm()
      perc <- perc[channelSelect(), input$samples]
      #Sys.sleep(0.3)
      return(gvisTable(as.data.frame(t(perc)), options=list(page='enable', 
                                                     height='automatic',
                                                     width='automatic')))
    })
    
    output$me_sample_choose <- renderUI({
      if(is.null(set)){
        return(NULL)
      }else{
        selectInput('me_sample_choose', 'Choose a sample:', 
                    choices = input$samples, width = "100%")
      }   
    })
    
    output$me_channel_choose <- renderUI({
      if(is.null(set)){
        return(NULL)
      }else{
        selectInput('me_channel_choose', 'Choose a Channel:', 
                    choices = channelSelect(), width = "100%")
      }   
    })
    
    meTimeData <- reactive({
      if(is.null(set))
        return(NULL)
      fcs <- fset()[[input$me_sample_choose]]
      exp <- fcs@exprs
      para <- pData(fcs@parameters)
      ranges <- range(fcs)
      time <- findTimeChannel(fcs)
      channel <- input$me_channel_choose
      tc <- as.data.frame(exp[ ,c(time, channel)])
      tc_range <- ranges[ ,channel]
      
      tc_neg <- tc[tc[,2] <= tc_range[1] - input$tol, ] 
      tc_pos <- tc[tc[,2] >= tc_range[2] + input$tol, ] 
      colnames(tc_pos) <- c("Time", "Upper Margin Events")
      colnames(tc_neg) <- c("Time", "Lower Margin Events")
      res <- merge(tc_pos, tc_neg, all = TRUE)
    })
    
    output$upMeTimePlot <- renderGvis({
      if(is.null(meTimeData()))
        return(NULL)
      upMeData <- as.data.frame(meTimeData())[,c(1,2)]
      Sys.sleep(0.3)
      gvisScatterChart(upMeData, options = list(pointSize = 0.5))
    })
    
    output$lowMeTimePlot <- renderGvis({
      if(is.null(meTimeData()))
        return(NULL)
      lowMeData <- as.data.frame(meTimeData())[,c(1,3)]
      if(nrow(lowMeData) > 2000){
        lowMeData <- lowMeData[sample(1:nrow(lowMeData), 2000), ]
      }
      Sys.sleep(0.3)
      gvisScatterChart(lowMeData, options = list(pointSize = 0.5)) 
    })
    
    output$meTime_text <- renderText({
      channelRange <- range(fset()[[input$me_sample_choose]])[ ,input$me_channel_choose]
      lower_thres <- round(channelRange[1] - input$tol, digits = 2)
      higher_thres <- round(channelRange[2] + input$tol, digits = 2)
      paste0("Lower threshold: ", lower_thres, ";    Upper threshold:", higher_thres)
    })
    
    ## render time flow plot
    output$s_tfplot <- renderPlot({
      if(is.null(set))
        return(NULL)
      timeFlowData <- fstf()$timeFlowData[input$samples]
      vcut <- input$tf_varCut
      timeFlowPlot(timeFlowData, timeThres(), vcut) 
    })
    
    output$tfplot <- renderGvis({
      if(is.null(set))
        return(NULL)
      tcord <- fstf_gvis()
      time <- tcord$time
      for (i in 1:length(set)){
        sample <- sampleNames(set)[i]
        timeRange <- timeThres()[[sample]]
        minTime <- timeRange[1]
        maxTime <- timeRange[2]
        badCellid <- time < minTime | time > maxTime
        tcord[[sample]][badCellid] <- NA
      }
      tcord <- subset(tcord, select = c(input$samples, "time"))
      gvisLineChart(tcord, xvar = "time", options=list(title="Cell Flow vs. Time") ) 
    })
    
    output$tf_text <- renderText({
      paste0("Bin size: ", fstf()$binSize)
    })
    
    
    ## render time line plot
    output$tl_sample_choose <- renderUI({
      if(is.null(fstl()$timeLineData)){
        return(NULL)
      }else{
        selectInput('tl_sample_choose', 'Choose a sample:', 
                    choices = input$samples, width = "80%")
      }   
    })
    
    
    output$s_tlplot <- renderPlot({
      if(is.null(fstl()$timeLineData))
        return(NULL)
      timeLineData <- fstl()$timeLineData[input$samples]
      timeLinePlot(lapply(timeLineData, function(x) x[[1]]), timeThres(),
                   channels = channelSelect())  
    })
    
    output$tlplot <- renderGvis({
      if(is.null(fstl()$timeLineData))
        return(NULL)
      timeLineData <- fstl()$timeLineData
      x <- timeLineData[[input$tl_sample_choose]]$res
      range <- timeThres()[[input$tl_sample_choose]]
      time <- x[ ,1]
      badCellid <- time < range[1] | time > range[2]
      x[badCellid,-1] <- NA
      x <- x[, c("time", channelSelect())]
      gvisLineChart(as.data.frame(x), xvar = "time", 
                    options=list(title="Timeline plot") )      
    })
    
    output$tl_text <- renderText({
      paste0("Bin size: ", fstl()$binSize)
    })
    
    output$tabplot1 <- renderPlot({
      if(is.null(fset()))
        return(NULL)
      x <- fset()
      flowQA_tabplot(x, input$tl_sample_choose, channels = channelSelect(),
                     binSize = fstl()$binSize)    
    })
    
    ## render score plot
    output$score_sample_choose <- renderUI({
      if(is.null(qaScore())){
        return(NULL)
      }else{
        selectInput('score_sample_choose', 'Choose a sample:', 
                    choices = input$samples, width = "100%")
      }   
    })
    
    output$sort_ID <- renderUI({
      if(is.null(qaScore())){
        return(NULL)
      }else{ 
        selectInput('sort_id', 'Sort column:', 
                    choices = colnames(qaScore()[[1]]) )
      }   
    })
    
    output$scoreplot <- renderPlot({
      if(is.null(qaScore()))
        return(NULL)
      sample <- input$score_sample_choose
      sid <- match(input$sort_id, colnames(qaScore()[[sample]]))
      
      flowQA_scoreplot(qaScore(), input$score_sample_choose, timeThres(), 
                       scoreThres = input$scoreThres,
                       sortID = sid, nBins = input$score_nrbins)    
    })
    
    ## data download
    output$downloadMarkers <- downloadHandler(
      filename = function() { 
        "markers.txt"
      },
      content = function(file) {
        write.table(channelSelect(), file, quote = FALSE,
                    row.names = FALSE, col.names = FALSE)
      }
    )
    
    output$downloadFCS <- downloadHandler(
      filename = function(){
        paste0("new_fcs_files", ".tar")
      },
      content = function(file){
        fsep = .Platform$file.sep
        tempdir = paste0(tempdir(), fsep, gsub("\\D", "_", Sys.time()))
        data <- fset()[input$samples]
        if(is.null(data)){
          return(NULL)
        }
        write.flowSet(data, tempdir)
        tar(tarfile = file, files = tempdir)
      }
    )
    
  })
  
  
  
  ####### aquí seguimos con los otros apartados de la web, estos están desarrollados desde 0 por mi, usando los diferentes paquetes mencionados
  #Gating
  ## Lectura del archivo FCS
  fcs_compensated <- reactive({
    if(is.null(input$compensate1FCSfile$datapath)){
      if(is.null(input$gatingFCSfile$datapath))
        return(NULL)
      isolate({gat_FCSfile <- input$gatingFCSfile$datapath
      fcs_gating <- FCScompensation_inluded(gat_FCSfile)})
      return(fcs_gating) 
    } else {
      if(is.null(input$gatingFCSfile$datapath))
        return(NULL)
      isolate({compensation_matrix <- input$compensate1FCSfile$datapath
      gat_FCSfile <- input$gatingFCSfile$datapath
      fcs_gating <- FCScompensation_provided(gat_FCSfile,compensation_matrix )})
      return(fcs_gating) 
    }
    
  })
  
  ##Plot FCS/SSC - sin hacer modificaciones, con los datos originales
  
  observeEvent(input$gating1_Button,
               {if (is.null(input$gating1_Button)) return(NULL)
                 plot_gating_1<- function()({
                   req(fcs_compensated())
                   if(is.null(fcs_compensated())) #importante, una vez definia una variable tras hacerla reactiva, para llamarla en otras habrá que tratarla como función, con ()
                     return(NULL)
                   plot1<-LSD::heatscatter(fcs_compensated()[, "FSC-A"],     
                                           fcs_compensated()[, "SSC-A"],
                                           cexplot = 0.3, main = "Raw FCS data", 
                                           xlab = "FSC-A", ylab = "SSC-A")
                   return(plot1)
                 })
                 
                 
                 output$FCSvsSSC_plot<- renderPlot({
                   plot_gating_1()
                 })
                
                 
                ##Para guardar el gráfico como png
                output$gating_graph1 <- downloadHandler(
                  filename = function(){
                    "RawFCSData_plot.png"
                  },
                  content = function(file){
                    png(file,
                        width = 1200,
                        height = 1200,
                        type = "cairo-png")
                        
                    plot_gating_1()
                    dev.off()
                  }
                )
                  
                   
                   ##Función de gating, creo una variable que cree la subpolación una vez recibido el input por el usuario y que lo almacene al dar al botón de submit
                   observeEvent(input$gating2_Button,
                                {
                                  if (is.null(input$gating2_Button)) return(NULL)
                                  req(fcs_compensated())
                                  
                                 
                                  gated_data<-try(gatingMatrix(fcs_compensated(),   
                                                           lower.gate = c(`FSC-A` = input$Lower_FSC, `SSC-A` = input$Lower_SSC),
                                                           upper.gate = c(`FSC-A` = input$Upper_FSC, `SSC-A` = input$Upper_SSC)), silent= FALSE, outFile = getOption("try.outFile", default = stderr()))
                                  if(class(gated_data)=="try-error"){
                                    showNotification("Please select a valid value, your range for gating is out of bound", duration=NULL, type = "message")
                                  }
                                  else {
                                  
                                  ## Ahora plotearía el gráfico con las poblaciones hechas el gating 
                                  
                                  plot_gating_2<- function(){
                                    req(gated_data)
                                    if(is.null(gated_data)) 
                                      return(NULL)
                                    plot2<-LSD::heatscatter(gated_data[, "FSC-A"],     
                                                     gated_data[, "SSC-A"],
                                                     cexplot = 0.3, main = "Gated FCS data", 
                                                     xlab = "FSC-A", ylab = "SSC-A") 
                                    return(plot2)
                                  }
                                  
                                  
                                  output$FCSvsSSC_gated_plot<- renderPlot({
                                    plot_gating_2()
                                  })
                                  }
                                  
                                  output$gating_graph2 <- downloadHandler(
                                    filename = function(){
                                      "Gated_FCSData_plot.png"
                                    },
                                    content = function(file){
                                      png(file,
                                          width = 1200,
                                          height = 1200,
                                          type = "cairo-png")
                                      plot_gating_2()
                                      dev.off()
                                    }
                                  )
                                  
                                     
                                    ##Crear un gráfico interactivo que tome las poblaciones del gating y permita visualizarlas eligiendo que marcadores representar
                                    
                                    #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                                    #xaxis
                                    output$gating_xaxis=renderUI({
                                      selectInput("gating_xaxis2", "Xaxis", colnames(gated_data))
                                    })
                                    
                                    #yaxis
                                    output$gating_yaxis=renderUI({
                                      selectInput("gating_yaxis2", "Yaxis", colnames(gated_data))
                                    })
                                    
                                    output$gated_interactive_plot<- renderPlotly({
                                      req(gated_data)
                                      if(is.null(gated_data)){
                                        return(NULL)} #dentro del objeto cyt.data.gating me interesa el slot de los marcadores
                                      gated_data2 <- as.data.frame(gated_data)
                                      xaxis <- input$gating_xaxis2
                                      yaxis <-input$gating_yaxis2
                                      gated_grafic <-plot_ly(gated_data2,type = "scatter",  x=gated_data2[,xaxis], y=gated_data2[,yaxis], mode="markers", colors="Paired")
                                      gated_grafic <-layout(gated_grafic, title="2D Plot of events after gating", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)))
                                    })  
                                  
                                  
                                  
                                }
                                
                   )
                   
                 
                 
               })
  
  
  
  
  
  
  
  
  
  
  
  
  #######CLUSTERING ####
  #lectura del archivo
  fcs_gating <- reactive({
    if(is.null(input$compensate2FCSfile$datapath)){
      if(is.null(input$clusteringFile$datapath))
        return(NULL)
      isolate({gat_FCSfile <- input$clusteringFile$datapath
      fcs_gating <- FCScompensation_inluded(gat_FCSfile)})
      return(fcs_gating) 
    } else {
      if(is.null(input$clusteringFile$datapath))
        return(NULL)
      isolate({compensation_matrix <- input$compensate2FCSfile$datapath
      gat_FCSfile <- input$clusteringFile$datapath
      fcs_gating <- FCScompensation_provided(gat_FCSfile,compensation_matrix )})
      return(fcs_gating) 
    }
    
  })
  
  #Normalización logarítmica tras la compensación de los datos
  
  observeEvent(input$clustering1_Button,
               if(is.null(fcs_gating())){
                 return(NULL)
               }
               else{
                 fcs_normalized <- createCYT(
                   raw.data = fcs_gating(),
                   normalization.method = "log",
                   verbose = TRUE
                 )
                 
                 ##Distintos métodos de clusterización
                 #marcamos la semilla que se usará para todos ellos
                 set.seed(1) #por defecto pondré que sea 1
                 ##MÉTODO SOM
                 cluster_som <- reactive({
                   
                   req(fcs_normalized) #poner como input raiz cuadrada de xdim ydim
                   cluster_som<-runCluster(fcs_normalized, cluster.method = "som", xdim=sqrt(input$som_number), ydim=sqrt(input$som_number), verbose = TRUE)
                   #tengo que incluir esta parte de procesado del clúster porque sino me da error la gŕafica
                   #el apartado de downsampling size sirve para disminuir el tamaño, pero si lo dejo en 1=100%
                   cluster_som<- processingCluster(cluster_som, downsampling.size = input$som_downsampling)#poner como input el valor de downsampling
                   return(cluster_som)
                   
                 })
                 
                 #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                 #xaxis
                 output$som_xaxis=renderUI({
                   selectInput("som_xaxis2", "Xaxis", colnames(cluster_som()@cluster))
                 })
                 
                 #yaxis
                 output$som_yaxis=renderUI({
                   selectInput("som_yaxis2", "Yaxis", colnames(cluster_som()@cluster))
                 })
                 #Gráfica método kmeans usando plotly
                 #primero obtengo la información del objeto cyt creado en el paso anterior
                 SOM_number_of_cells <- reactive({
                   
                   req(cluster_som()) #poner como input raiz cuadrada de xdim ydim
                   cluster_id <- cluster_som()@meta.data$cluster.id #saco el nombre de los clúster
                   number_of_cells<-as.data.frame(table(cluster_id), row.names = row.names(cluster_som()@cluster)) #creo un data frame que recoge el número de células que tiene cada clúster
                   return(number_of_cells)
                   
                 })
                 
                 #Y creo el plot correspondiente
                 output$SOM_plot<- renderPlotly({
                   req(cluster_som())
                   if(is.null(cluster_som())){
                     return(NULL)} #dentro del objeto cyt me interesa el slot de cluster, este recoge la información sobre los clúster formados
                   xaxis <- input$som_xaxis2
                   yaxis <-input$som_yaxis2
                   #prueba para arreglar el tema de la paleta de colores
                   number_colors <- nrow(cluster_som()@cluster)
                   mycolors=colorRampPalette(brewer.pal(12, "Paired"))(number_colors)
                   grafico_som <-plot_ly(cluster_som()@cluster,type = "scatter",  x=cluster_som()@cluster[,xaxis], y=cluster_som()@cluster[,yaxis], mode="markers", text= paste("Cluster ", row.names(cluster_som()@cluster), "<br>Numer of events ", SOM_number_of_cells()$Freq), color = row.names(cluster_som()@cluster) , colors=mycolors, size=SOM_number_of_cells()$Freq)
                   grafico_som <-layout(grafico_som, title="2D Plot of Cluster using SOM Method", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)), legend=list(tittle=list(text="Cluster:")))
                 })
                 
                 
                 ##MÉTODO K-MEANS
                 cluster_kmeans <- reactive({
                   
                   req(fcs_normalized) #poner como input la k
                   cluster_kmeans<-runCluster(fcs_normalized, cluster.method = "kmeans", k=input$k_number, iter.max=30)
                   cluster_kmeans<- processingCluster(cluster_kmeans, downsampling.size = input$k_downsampling) #poner como input el valor de downsampling
                   return(cluster_kmeans)
                   
                 })
                 
                 #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                 #xaxis
                 output$kmeans_xaxis=renderUI({
                   selectInput("kmeans_xaxis2", "Xaxis", colnames(cluster_kmeans()@cluster))
                 })
                 
                 #yaxis
                 output$kmeans_yaxis=renderUI({
                   selectInput("kmeans_yaxis2", "Yaxis", colnames(cluster_kmeans()@cluster))
                 })
                 #Gráfica método kmeans usando plotly
                 #primero obtengo la información del objeto cyt creado en el paso anterior
                 KMEANS_number_of_cells <- reactive({
                   
                   req(cluster_kmeans()) #poner como input raiz cuadrada de xdim ydim
                   cluster_id <- cluster_kmeans()@meta.data$cluster.id #saco el nombre de los clúster
                   number_of_cells<-as.data.frame(table(cluster_id), row.names = row.names(cluster_kmeans()@cluster)) #creo un data frame que recoge el número de células que tiene cada clúster
                   return(number_of_cells)
                   
                 })
                 
                 #Y creo el plot correspondiente
                 output$KMEANS_plot<- renderPlotly({
                   req(cluster_kmeans())
                   if(is.null(cluster_kmeans())){
                     return(NULL)} #dentro del objeto cyt me interesa el slot de cluster, este recoge la información sobre los clúster formados
                   xaxis <- input$kmeans_xaxis2
                   yaxis <-input$kmeans_yaxis2
                   number_colors <- nrow(cluster_kmeans()@cluster)
                   mycolors=colorRampPalette(brewer.pal(12, "Paired"))(number_colors)
                   grafico_kmeans <-plot_ly(cluster_kmeans()@cluster,type = "scatter",  x=cluster_kmeans()@cluster[,xaxis], y=cluster_kmeans()@cluster[,yaxis], mode="markers", text= paste("Cluster ", row.names(cluster_kmeans()@cluster), "<br>Numer of events ", KMEANS_number_of_cells()$Freq), color = row.names(cluster_kmeans()@cluster), colors=mycolors, size=KMEANS_number_of_cells()$Freq)
                   grafico_kmeans <-layout(grafico_kmeans, title="2D Plot of Cluster using KMEANS Method", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)), legend=list(tittle=list(text="Cluster:")))
                 })
                 
                 
                 ##ALGORITMO CLARA
                 cluster_clara <- reactive({
                   req(fcs_normalized) 
                   cluster_clara<-runCluster(fcs_normalized, cluster.method = "clara", k=input$clara_number)
                   cluster_clara<- processingCluster(cluster_clara, downsampling.size = input$clara_downsampling) #poner como input el valor de downsampling
                   return(cluster_clara)
                   
                 })
                 
                 #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                 #xaxis
                 output$clara_xaxis=renderUI({
                   selectInput("clara_xaxis2", "Xaxis", colnames(cluster_clara()@cluster))
                 })
                 
                 #yaxis
                 output$clara_yaxis=renderUI({
                   selectInput("clara_yaxis2", "Yaxis", colnames(cluster_clara()@cluster))
                 })
                 
                 #Gráfica método CLARA usando plotly
                 #primero obtengo la información del objeto cyt creado en el paso anterior
                 CLARA_number_of_cells <- reactive({
                   
                   req(cluster_clara()) #poner como input raiz cuadrada de xdim ydim
                   cluster_id <- cluster_clara()@meta.data$cluster.id #saco el nombre de los clúster
                   number_of_cells<-as.data.frame(table(cluster_id), row.names = row.names(cluster_clara()@cluster)) #creo un data frame que recoge el número de células que tiene cada clúster
                   return(number_of_cells)
                   
                 })
                 
                 #Y creo el plot correspondiente
                 output$CLARA_plot<- renderPlotly({
                   req(cluster_clara())
                   if(is.null(cluster_clara())){
                     return(NULL)} #dentro del objeto cyt me interesa el slot de cluster, este recoge la información sobre los clúster formados
                   xaxis <- input$clara_xaxis2
                   yaxis <-input$clara_yaxis2
                   number_colors <- nrow(cluster_clara()@cluster)
                   mycolors=colorRampPalette(brewer.pal(12, "Paired"))(number_colors)
                   grafico_clara <-plot_ly(cluster_clara()@cluster,type = "scatter",  x=cluster_clara()@cluster[,xaxis], y=cluster_clara()@cluster[,yaxis], mode="markers", text= paste("Cluster ", row.names(cluster_clara()@cluster), "<br>Numer of events ", CLARA_number_of_cells()$Freq), color = row.names(cluster_clara()@cluster), colors=mycolors, size=CLARA_number_of_cells()$Freq)
                   grafico_clara <-layout(grafico_clara, title="2D Plot of Cluster using CLARA Method", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)), legend=list(tittle=list(text="Cluster:")))
                 })
                 
                 ##ALGORITMO PHENOGRAPH ##usarlo solo cuando el número de células sea menor de 10000, sino tomará demasiado tiempo
                 cluster_phenograph <- reactive({
                   req(fcs_normalized) 
                   cluster_phenograph<-runCluster(fcs_normalized, cluster.method = "phenograph")
                   cluster_phenograph<- processingCluster(cluster_phenograph, downsampling.size = input$pheno_downsampling) #poner como input el valor de downsampling
                   return(cluster_phenograph)
                   
                 })
                 
                 #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                 #xaxis
                 output$pheno_xaxis=renderUI({
                   selectInput("pheno_xaxis2", "Xaxis", colnames(cluster_phenograph()@cluster))
                 })
                 
                 #yaxis
                 output$pheno_yaxis=renderUI({
                   selectInput("pheno_yaxis2", "Yaxis", colnames(cluster_phenograph()@cluster))
                 })
                 
                 #Gráfica método pheno usando plotly
                 #primero obtengo la información del objeto cyt creado en el paso anterior
                 pheno_number_of_cells <- reactive({
                   
                   req(cluster_phenograph()) #poner como input raiz cuadrada de xdim ydim
                   cluster_id <- cluster_phenograph()@meta.data$cluster.id #saco el nombre de los clúster
                   number_of_cells<-as.data.frame(table(cluster_id), row.names = row.names(cluster_phenograph()@cluster)) #creo un data frame que recoge el número de células que tiene cada clúster
                   return(number_of_cells)
                   
                 })
                 
                 #Y creo el plot correspondiente
                 output$PHENO_plot<- renderPlotly({
                   req(cluster_phenograph())
                   if(is.null(cluster_phenograph())){
                     return(NULL)} #dentro del objeto cyt me interesa el slot de cluster, este recoge la información sobre los clúster formados
                   xaxis <- input$pheno_xaxis2
                   yaxis <-input$pheno_yaxis2
                   number_colors <- nrow(cluster_phenograph()@cluster)
                   mycolors=colorRampPalette(brewer.pal(12, "Paired"))(number_colors)
                   grafico_pheno <-plot_ly(cluster_phenograph()@cluster,type = "scatter",  x=cluster_phenograph()@cluster[,xaxis], y=cluster_phenograph()@cluster[,yaxis], mode="markers", text= paste("Cluster ", row.names(cluster_phenograph()@cluster), "<br>Numer of events ", pheno_number_of_cells()$Freq), color = row.names(cluster_phenograph()@cluster), colors=mycolors, size=pheno_number_of_cells()$Freq)
                   grafico_pheno <-layout(grafico_pheno, title="2D Plot of Cluster using pheno Method", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)), legend=list(tittle=list(text="Cluster:")))
                 })
                 
                 ##ALGORITMO HCLUST ##usarlo solo cuando el número de células sea menor de 50000, sino tomará demasiado tiempo
                 cluster_hclust <- reactive({
                   req(fcs_normalized) 
                   cluster_hclust<-runCluster(fcs_normalized, cluster.method = "hclust", k=input$h_number)
                   cluster_hclust<- processingCluster(cluster_hclust, downsampling.size = input$h_downsampling) #poner como input el valor de downsampling
                   return(cluster_hclust)
                   
                 })
                 
                 #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                 #xaxis
                 output$hclust_xaxis=renderUI({
                   selectInput("hclust_xaxis2", "Xaxis", colnames(cluster_hclust()@cluster))
                 })
                 
                 #yaxis
                 output$hclust_yaxis=renderUI({
                   selectInput("hclust_yaxis2", "Yaxis", colnames(cluster_hclust()@cluster))
                 })
                 
                 #Gráfica método hclust usando plotly
                 #primero obtengo la información del objeto cyt creado en el paso anterior
                 hclust_number_of_cells <- reactive({
                   
                   req(cluster_hclust()) #poner como input raiz cuadrada de xdim ydim
                   cluster_id <- cluster_hclust()@meta.data$cluster.id #saco el nombre de los clúster
                   number_of_cells<-as.data.frame(table(cluster_id), row.names = row.names(cluster_hclust()@cluster)) #creo un data frame que recoge el número de células que tiene cada clúster
                   return(number_of_cells)
                   
                 })
                 
                 #Y creo el plot correspondiente
                 output$HCLUST_plot<- renderPlotly({
                   req(cluster_hclust())
                   if(is.null(cluster_hclust())){
                     return(NULL)} #dentro del objeto cyt me interesa el slot de cluster, este recoge la información sobre los clúster formados
                   xaxis <- input$hclust_xaxis2
                   yaxis <-input$hclust_yaxis2
                   number_colors <- nrow(cluster_hclust()@cluster)
                   mycolors=colorRampPalette(brewer.pal(12, "Paired"))(number_colors)
                   grafico_hclust <-plot_ly(cluster_hclust()@cluster,type = "scatter",  x=cluster_hclust()@cluster[,xaxis], y=cluster_hclust()@cluster[,yaxis], mode="markers", text= paste("Cluster ", row.names(cluster_hclust()@cluster), "<br>Numer of events ", hclust_number_of_cells()$Freq), color = row.names(cluster_hclust()@cluster), colors=mycolors, size=hclust_number_of_cells()$Freq)
                   grafico_hclust <-layout(grafico_hclust, title="2D Plot of Cluster using hclust Method", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)), legend=list(tittle=list(text="Cluster:")))
                 })
                 
                 ##ALGORITMO PHENOGRAPH ##usarlo solo cuando el número de células sea menor de 10000, sino tomará demasiado tiempo
                 cluster_phenograph <- reactive({
                   req(fcs_normalized) 
                   cluster_phenograph<-runCluster(fcs_normalized, cluster.method = "phenograph")
                   cluster_phenograph<- processingCluster(cluster_phenograph, downsampling.size = input$pheno_downsampling) #poner como input el valor de downsampling
                   return(cluster_phenograph)
                   
                 })
                 
                 #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                 #xaxis
                 output$pheno_xaxis=renderUI({
                   selectInput("pheno_xaxis2", "Xaxis", colnames(cluster_phenograph()@cluster))
                 })
                 
                 #yaxis
                 output$pheno_yaxis=renderUI({
                   selectInput("pheno_yaxis2", "Yaxis", colnames(cluster_phenograph()@cluster))
                 })
                 
                 #Gráfica método pheno usando plotly
                 #primero obtengo la información del objeto cyt creado en el paso anterior
                 pheno_number_of_cells <- reactive({
                   
                   req(cluster_phenograph()) #poner como input raiz cuadrada de xdim ydim
                   cluster_id <- cluster_phenograph()@meta.data$cluster.id #saco el nombre de los clúster
                   number_of_cells<-as.data.frame(table(cluster_id), row.names = row.names(cluster_phenograph()@cluster)) #creo un data frame que recoge el número de células que tiene cada clúster
                   return(number_of_cells)
                   
                 })
                 
                 #Y creo el plot correspondiente
                 output$PHENO_plot<- renderPlotly({
                   req(cluster_phenograph())
                   if(is.null(cluster_phenograph())){
                     return(NULL)} #dentro del objeto cyt me interesa el slot de cluster, este recoge la información sobre los clúster formados
                   xaxis <- input$pheno_xaxis2
                   yaxis <-input$pheno_yaxis2
                   number_colors <- nrow(cluster_phenograph()@cluster)
                   mycolors=colorRampPalette(brewer.pal(12, "Paired"))(number_colors)
                   grafico_pheno <-plot_ly(cluster_phenograph()@cluster,type = "scatter",  x=cluster_phenograph()@cluster[,xaxis], y=cluster_phenograph()@cluster[,yaxis], mode="markers", text= paste("Cluster ", row.names(cluster_phenograph()@cluster), "<br>Numer of events ", pheno_number_of_cells()$Freq), color = row.names(cluster_phenograph()@cluster), colors=mycolors, size=pheno_number_of_cells()$Freq)
                   grafico_pheno <-layout(grafico_pheno, title="2D Plot of Cluster using pheno Method", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)), legend=list(tittle=list(text="Cluster:")))
                 })
                 
                 ##ALGORITMO MCLUST ##usarlo solo cuando el número de células sea menor de 50000, sino tomará demasiado tiempo
                 cluster_mclust <- reactive({
                   req(fcs_normalized) 
                   cluster_mclust<-runCluster(fcs_normalized, cluster.method = "mclust", k=input$m_number)
                   cluster_mclust<- processingCluster(cluster_mclust, perplexity = input$m_perplexity, downsampling.size = input$m_downsampling) #poner como input el valor de downsampling
                   return(cluster_mclust)
                   
                 })
                 
                 #Aquí saco la relacción de variables para el eje X e y que se usará en la parte de UI como input de selección múltiple
                 #xaxis
                 output$mclust_xaxis=renderUI({
                   selectInput("mclust_xaxis2", "Xaxis", colnames(cluster_mclust()@cluster))
                 })
                 
                 #yaxis
                 output$mclust_yaxis=renderUI({
                   selectInput("mclust_yaxis2", "Yaxis", colnames(cluster_mclust()@cluster))
                 })
                 
                 #Gráfica método mclust usando plotly
                 #primero obtengo la información del objeto cyt creado en el paso anterior
                 mclust_number_of_cells <- reactive({
                   
                   req(cluster_mclust()) #poner como input raiz cuadrada de xdim ydim
                   cluster_id <- cluster_mclust()@meta.data$cluster.id #saco el nombre de los clúster
                   number_of_cells<-as.data.frame(table(cluster_id), row.names = row.names(cluster_mclust()@cluster)) #creo un data frame que recoge el número de células que tiene cada clúster
                   return(number_of_cells)
                   
                 })
                 
                 #Y creo el plot correspondiente
                 output$MCLUST_plot<- renderPlotly({
                   req(cluster_mclust())
                   if(is.null(cluster_mclust())){
                     return(NULL)} #dentro del objeto cyt me interesa el slot de cluster, este recoge la información sobre los clúster formados
                   xaxis <- input$mclust_xaxis2
                   yaxis <-input$mclust_yaxis2
                   number_colors <- nrow(cluster_mclust()@cluster)
                   mycolors=colorRampPalette(brewer.pal(12, "Paired"))(number_colors)
                   grafico_mclust <-plot_ly(cluster_mclust()@cluster,type = "scatter",  x=cluster_mclust()@cluster[,xaxis], y=cluster_mclust()@cluster[,yaxis], mode="markers", text= paste("Cluster ", row.names(cluster_mclust()@cluster), "<br>Numer of events ", mclust_number_of_cells()$Freq), color = row.names(cluster_mclust()@cluster), colors=mycolors, size=mclust_number_of_cells()$Freq)
                   grafico_mclust <-layout(grafico_mclust, title="2D Plot of Cluster using mclust Method", xaxis=list(title=toString(xaxis)), yaxis=list(title=toString(yaxis)), legend=list(tittle=list(text="Cluster:")))
                 })
               })
  
  
  
  
  
  
  
  
  
  
}

###Parte 3, llamada o creación de la app:
shinyApp(ui=ui, server=server)
