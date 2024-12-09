library(shiny)
library(bs4Dash)
library(highcharter)
library(DT)
library(leaflet)
library(sf)
library(dplyr)
library(readxl)
library(jsonlite)
library(tidyr)

# Define color palette based on NSDP Logo colors
color_palette <- list(
  black = "#000000",
  celadon = "#A9DABA",
  baby_powder = "#F3F4EF",
  rosewood = "#6F1819",
  sea_green = "#108F46",
  jasmine = "#F6D67B",
  earth_yellow = "#D3A766",
  fire_brick = "#B73334"
)

ui <- dashboardPage(
  help = NULL,
  fullscreen = TRUE,
  scrollToTop = TRUE,
  
  title = "NSDP Dashboard",
  
  header = dashboardHeader(
    title = dashboardBrand(
      title = "NSDP Dashboard",
      image = "nsdp_icon.png"
    ),
    controlbarIcon = icon("filter"),
    rightUi = tags$li(
      class = "dropdown",
      actionButton("help_btn", "Help", icon = icon("question-circle"), class = "btn-info")
    )
  ),
  
  sidebar = dashboardSidebar(
    skin = "light",
    status = "primary",
    sidebarMenu(
      id = "sidebar",
      menuItem("Overview", tabName = "overview", icon = icon("home")),
      menuItem("Impact of Shocks on HH", tabName = "shocks", icon = icon("bolt"))
    )
  ),
  
  controlbar = dashboardControlbar(
    overlay = TRUE,
    pinned = NULL,
    selectInput(
      inputId = "provinceFilter",
      label = "Select Province:",
      choices = c("All", "Torba", "Sanma rural", "Penama", "Malampa", "Shefa rural"),
      selected = "All"
    )
  ),
  
  footer = dashboardFooter(
    right = "© 2024 Vanuatu Bureau of Statistics. All rights reserved."
  ),
  
  dashboardBody(
    tags$style(HTML(paste0("
    .modal-dialog {
      max-width: 90% !important;
    }
    .nav-sidebar .nav-item > .nav-link.active {
      background-color: ", color_palette$sea_green, " !important;
      color: ", color_palette$baby_powder, " !important;
    }
    .nav-sidebar .nav-item > .nav-link:hover {
      background-color: ", color_palette$celadon, " !important;
      color: ", color_palette$black, " !important;
    }
     .card:hover {
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
      transition: box-shadow 0.3s ease-in-out;
    }
  "))),
    
    tabItems(
      # Overview Tab
      tabItem(
        tabName = "overview",
        fluidRow(
          column(
            width = 4,
            infoBoxOutput("totHHAffected", width = 12)
          ),
          column(
            width = 4,
            infoBoxOutput("mostCommonShockType", width = 12)
          ),
          column(
            width = 4,
            infoBoxOutput("percentageHHAffectedTop3Shocks", width = 12)
          )
        ),
        fluidRow(
          box(
            title = "Distribution of households affected by shock type",
            width = 6,
            collapsible = FALSE,
            maximizable = TRUE,
            sidebar = boxSidebar(
              id = "distBoxSidebar",
              p(
                "This chart highlights the distribution of households affected by different shock types. 
                Cyclones account for a substantial proportion of affected households, suggesting their 
    dominance as a severe and frequent shock in the region. Other shocks, such as droughts or 
    earthquakes, might show comparatively lower numbers but still represent critical challenges 
    for resilience and recovery"
              )
            ),
            highchartOutput("distributionBarChart", height = "400px")
          ),
          box(
            title = "Proportion of top 3 severe shocks",
            width = 6,
            collapsible = FALSE,
            maximizable = TRUE,
            sidebar = boxSidebar(
              id = "pieBoxSidebar",
              p(
                "This pie chart illustrates the proportion of households affected by the top three most severe shocks 
  in the selected province. The chart highlights the dominant shocks, providing insight into the 
  most significant challenges faced by households in the region. Use this visualization to identify 
  which shocks contribute most to the overall impact and prioritize response strategies accordingly."
              )
              
            ),
            highchartOutput("proportionPieChart", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Regional Breakdown of Shocks by Province",
            width = 12,
            collapsible = FALSE,
            maximizable = TRUE,
            leafletOutput("regionalBreakdownMap", height = "600px")
          )
        )
      ),
      
      # Affected by Shocks Tab
      tabItem(
        tabName = "shocks",
        fluidRow(
          box(
            title = "Filterable Table of Affected Households",
            width = 12,
            collapsible = TRUE,
            maximizable = TRUE,
            DTOutput("shockTable"),
            downloadButton("downloadFiltered", "Download Filtered Table", class = "btn-success")
          )
        )
      )
    )
  )
  
)

server <- function(input, output, session) {
  
  # Trigger the modal dialog when the "Help" button is clicked
  observeEvent(input$help_btn, {
    showModal(modalDialog(
      title = "NSDP Dashboard Help",
      tags$p("Welcome to the NSDP Dashboard!"),
      tags$ul(
        tags$li("Use the filters in the control bar to refine the data."),
        tags$li("Navigate through the sidebar to access different sections."),
        tags$li("Visualize data using the interactive charts displayed in the body."),
        tags$li("For more information, contact the Vanuatu Bureau of Statistics.")
      ),
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
  
  # Load the datasets
  map_dataset <- read.csv("data/numberHHAffectedBy.csv")
  
  # Example coordinates for provinces
  coordinates <- data.frame(
    Province = c("Torba", "Sanma rural", "Penama", "Malampa", "Shefa rural"),
    latitude = c(-13.5, -15.5, -15.2, -16.3, -17.7),
    longitude = c(167.3, 167.2, 168.0, 167.6, 168.3)
  )
  
  # Merge coordinates with the dataset
  map_data <- map_dataset %>%
    mutate(
      total_affected = Cyclone +
        HeavyRain_flooding_tsunami +
        Earthquake +
        VolcanicEruption_ashFall +
        BushFire +
        CropDisease +
        Drought +
        LossofMoney_anyReason +
        AnimalDiseaseorLoss +
        OtherShock
    ) %>%
    select(Province, total_affected, Cyclone, HeavyRain_flooding_tsunami, Earthquake,
           VolcanicEruption_ashFall, BushFire, CropDisease, Drought,
           LossofMoney_anyReason, AnimalDiseaseorLoss, OtherShock) %>%
    left_join(coordinates, by = "Province")
  
  # Reactive filter for province selection
  filtered_data <- reactive({
    if (input$provinceFilter == "All") {
      map_data
    } else {
      map_data %>% filter(Province == input$provinceFilter)
    }
  })
  
  # Render the Leaflet map
  output$regionalBreakdownMap <- renderLeaflet({
    filtered_map_data <- filtered_data()
    
    leaflet(data = filtered_map_data) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~longitude, lat = ~latitude,
        radius = ~total_affected / 1000, # Adjust scale as needed
        label = ~paste0("Province: ", Province, " - Total Affected: ", total_affected),
        labelOptions = labelOptions(
          style = list("font-weight" = "bold", "color" = "black", "font-size" = "12px"),
          direction = "auto",
          opacity = 0.8,
          permanent = FALSE
        ),
        color = "blue",
        fillColor = "blue",
        fillOpacity = 0.6
      ) %>%
      setView(lng = 168, lat = -16.5, zoom = 7)
  })
  
  # Update charts and KPIs based on the filter
  output$totHHAffected <- renderInfoBox({
    total_affected <- filtered_data() %>%
      summarise(total = sum(total_affected, na.rm = TRUE)) %>%
      pull(total)
    
    infoBox(
      title = "Households Affected",
      value = prettyNum(total_affected, big.mark = ","),
      icon = icon("users"),
      color = "lime"
    )
  })
  
  output$mostCommonShockType <- renderInfoBox({
    most_common_shock <- filtered_data() %>%
      summarise(
        Cyclone = sum(Cyclone, na.rm = TRUE),
        HeavyRain_flooding_tsunami = sum(HeavyRain_flooding_tsunami, na.rm = TRUE),
        Earthquake = sum(Earthquake, na.rm = TRUE),
        VolcanicEruption_ashFall = sum(VolcanicEruption_ashFall, na.rm = TRUE),
        BushFire = sum(BushFire, na.rm = TRUE),
        CropDisease = sum(CropDisease, na.rm = TRUE),
        Drought = sum(Drought, na.rm = TRUE),
        LossofMoney_anyReason = sum(LossofMoney_anyReason, na.rm = TRUE),
        AnimalDiseaseorLoss = sum(AnimalDiseaseorLoss, na.rm = TRUE),
        OtherShock = sum(OtherShock, na.rm = TRUE)
      ) %>%
      pivot_longer(cols = everything(), names_to = "ShockType", values_to = "TotalAffected") %>%
      arrange(desc(TotalAffected)) %>%
      slice(1) %>%
      pull(ShockType)
    
    infoBox(
      title = "Common Shock",
      value = most_common_shock,
      icon = icon("wind"),
      color = "lime"
    )
  })
  
  output$percentageHHAffectedTop3Shocks <- renderInfoBox({
    total_affected <- filtered_data() %>%
      summarise(total = sum(total_affected, na.rm = TRUE)) %>%
      pull(total)
    
    top_3_affected <- filtered_data() %>%
      summarise(
        Cyclone = sum(Cyclone, na.rm = TRUE),
        HeavyRain_flooding_tsunami = sum(HeavyRain_flooding_tsunami, na.rm = TRUE),
        Earthquake = sum(Earthquake, na.rm = TRUE),
        VolcanicEruption_ashFall = sum(VolcanicEruption_ashFall, na.rm = TRUE),
        BushFire = sum(BushFire, na.rm = TRUE),
        CropDisease = sum(CropDisease, na.rm = TRUE),
        Drought = sum(Drought, na.rm = TRUE),
        LossofMoney_anyReason = sum(LossofMoney_anyReason, na.rm = TRUE),
        AnimalDiseaseorLoss = sum(AnimalDiseaseorLoss, na.rm = TRUE),
        OtherShock = sum(OtherShock, na.rm = TRUE)
      ) %>%
      pivot_longer(cols = everything(), names_to = "ShockType", values_to = "TotalAffected") %>%
      arrange(desc(TotalAffected)) %>%
      slice(1:3) %>%
      summarise(top_3_total = sum(TotalAffected)) %>%
      pull(top_3_total)
    
    percentage_top_3 <- (top_3_affected / total_affected) * 100
    
    infoBox(
      title = "Top 3 Affected",
      value = paste0(round(percentage_top_3, 1), "%"),
      icon = icon("percent"),
      color = "lime"
    )
  })
  
  # Distribution Bar Chart
  output$distributionBarChart <- renderHighchart({
    # Use filtered data
    shock_data <- filtered_data() %>%
      summarise(
        Cyclone = sum(Cyclone, na.rm = TRUE),
        HeavyRain_flooding_tsunami = sum(HeavyRain_flooding_tsunami, na.rm = TRUE),
        Earthquake = sum(Earthquake, na.rm = TRUE),
        VolcanicEruption_ashFall = sum(VolcanicEruption_ashFall, na.rm = TRUE),
        BushFire = sum(BushFire, na.rm = TRUE),
        CropDisease = sum(CropDisease, na.rm = TRUE),
        Drought = sum(Drought, na.rm = TRUE),
        LossofMoney_anyReason = sum(LossofMoney_anyReason, na.rm = TRUE),
        AnimalDiseaseorLoss = sum(AnimalDiseaseorLoss, na.rm = TRUE),
        OtherShock = sum(OtherShock, na.rm = TRUE)
      ) %>%
      pivot_longer(cols = everything(), names_to = "ShockType", values_to = "TotalAffected") %>%
      arrange(desc(TotalAffected))
    
    highchart() %>%
      hc_chart(type = "column") %>%
      hc_xAxis(
        categories = shock_data$ShockType,
        title = list(text = "Shock Type")
      ) %>%
      hc_yAxis(
        title = list(text = "Total Affected Households")
      ) %>%
      hc_add_series(
        name = "Households Affected",
        data = shock_data$TotalAffected
      ) %>%
      hc_tooltip(pointFormat = "Total Affected: {point.y}") %>%
      hc_exporting(
        enabled = TRUE
      ) %>%
      hc_colors(color_palette$sea_green)
  })
  # Proportion of Top 3 Severe Shocks (Pie Chart)
  output$proportionPieChart <- renderHighchart({
    shock_data <- filtered_data() %>%
      summarise(
        Cyclone = sum(Cyclone, na.rm = TRUE),
        HeavyRain_flooding_tsunami = sum(HeavyRain_flooding_tsunami, na.rm = TRUE),
        Earthquake = sum(Earthquake, na.rm = TRUE),
        VolcanicEruption_ashFall = sum(VolcanicEruption_ashFall, na.rm = TRUE),
        BushFire = sum(BushFire, na.rm = TRUE),
        CropDisease = sum(CropDisease, na.rm = TRUE),
        Drought = sum(Drought, na.rm = TRUE),
        LossofMoney_anyReason = sum(LossofMoney_anyReason, na.rm = TRUE),
        AnimalDiseaseorLoss = sum(AnimalDiseaseorLoss, na.rm = TRUE),
        OtherShock = sum(OtherShock, na.rm = TRUE)
      ) %>%
      pivot_longer(
        cols = everything(),
        names_to = "ShockType",
        values_to = "TotalAffected"
      ) %>%
      arrange(desc(TotalAffected)) %>% 
      slice(1:3) # Select top 3 severe shocks
    
    # Prepare data for Highcharter
    pie_data <- shock_data %>%
      mutate(Percentage = (TotalAffected / sum(TotalAffected)) * 100) %>%
      list_parse2() # Convert to Highchart-friendly format
    
    # Render the pie chart
    highchart() %>%
      hc_chart(type = "pie") %>%
      hc_title(text = "Top 3 Severe Shocks") %>%
      hc_add_series(
        name = "Households Affected",
        data = pie_data
      ) %>%
      hc_tooltip(
        pointFormat = "<b>{point.name}</b>: {point.percentage:.1f}%"
      ) %>%
      hc_plotOptions(
        pie = list(
          dataLabels = list(
            enabled = TRUE,
            format = "<b>{point.name}</b>: {point.percentage:.1f}%"
          )
        )
      ) %>%
      hc_exporting(
        enabled = TRUE
      ) %>%
      hc_colors(c(
        color_palette$sea_green,
        color_palette$jasmine,
        color_palette$fire_brick
      )) # Colors for top 3 shocks
  })
  
  shock_data_reactive <- reactive({
    shock_data <- read.csv("data/shockFigures.csv")
    shock_data
  })
  
  # Render the filterable table
  output$shockTable <- renderDT({
    datatable(
      shock_data_reactive(),
      extensions = 'Buttons',
      filter = 'top',
      options = list(
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf'),
        pageLength = 10,
        autoWidth = TRUE
      )
    )
  })
  
  # Download filtered data
  output$downloadFiltered <- downloadHandler(
    filename = function() {
      paste("filtered_shock_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(shock_data_reactive(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)
