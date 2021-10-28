show_raster <- function(r, pal = NULL, proxy = FALSE, graticule_interval = 5) {
    if (is.null(pal)) {
          pal <- colorNumeric(terrain.colors(10), values(r), na.color = "transparent")
      }
    FUN <- ifelse(proxy, leafletProxy, leaflet)

    p <- FUN("map") %>%
        addTiles(group = "OSM (default)") %>%
        addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>%
        addProviderTiles(providers$Esri.WorldStreetMap, group = "Esri.WorldStreetMap") %>%
        addRasterImage(r,
            opacity = 0.4, project = FALSE, layerId = "Example",
            group = "raster",
            colors = pal
        ) %>%
        addLegend(pal = pal, values = values(r), opacity = 1, title = names(r)) %>%
        addScaleBar(position = "bottomleft") %>%
        addGraticule(
            interval = graticule_interval,
            style = list(color = "#999", weight = 1)
        ) %>%
        addLayersControl(
            baseGroups = c("Esri.WorldImagery", "Esri.WorldStreetMap", "OSM (default)"),
            overlayGroups = c("raster"),
            options = layersControlOptions(collapsed = FALSE)
        )
    suppressWarnings(p)
}

show_popup <- function(r, lon = NULL, lat = NULL) { # Show popup on clicks
    # Translate Lat-Lon to cell number using the unprojected raster
    # This is because the projected raster is not in degrees, we cannot use it!
    cell <- cellFromXY(r, c(lon, lat))
    c(dx, dy) %<-% res(r)
    c(nrow, ncol) %<-% dim(r)[1:2]

    if (!is.na(cell)) { # If the click is inside the raster...
        xy <- xyFromCell(r, cell) # Get the center of the cell
        x <- xy[1]
        y <- xy[2]
        c(i, j) %<-% rowColFromCell(r, cell) # Get row and column, to print later
        
        val <- r[cell] %>% paste(collapse = ", ") # Get value of the given cell
        content <- glue("i={i}, j = {j}, cell = {cell}; lon = {round(x, 5)}, lat = {round(y, 5)}, val = {val}")
        cell2 = (i - 1) * ncol + j
        print(cell2)

        proxy <- leafletProxy("map")
        proxy %>%
            clearPopups() %>%
            addPopups(x, y, popup = content) # add Popup
        # add rectangles for testing
        proxy %>%
            clearShapes() %>%
            addRectangles(x - dx / 2, y - dy / 2, x + dx / 2, y + dy / 2)
    }
}

#' rasterInspect
#' 
#' @export
rasterInspect <- function(r, fun_raster = show_raster, fun_popup = show_popup, port = 81) {
    ext <- extent(r)
    resol <- res(r)
    # options = leafletOptions(crs = leafletCRS("L.CRS.EPSG4326", "EPSG:4326"))
    # sbwidth=200
    # sidebar <- dashboardSidebar(width=sbwidth)
    sbwidth <- 0
    body <- dashboardBody(
        # https://stackoverflow.com/questions/31278938/how-can-i-make-my-shiny-leafletoutput-have-height-100-while-inside-a-navbarpa
        box(div(
            class = "outer", width = NULL, solidHeader = TRUE,
            tags$style(
                type = "text/css",
                paste0(".outer {position: fixed; top: 50px; left: ", sbwidth, "px; right: 0; bottom: 0px; overflow: hidden; padding: 0}")
            ),
            leafletOutput("map", width = "100%", height = "100%")
        ))
    )
    # ui <- dashboardPage( dashboardHeader(title = "A title"), sidebar, body)
    ui <- fluidPage(fluidRow(body))

    # Server instance
    server <- function(input, output, session) {
        output$map <- renderLeaflet({ # Set extent
            # options = options
            leaflet() %>%
                fitBounds(ext[1], ext[3], ext[2], ext[4])
        })
        observe({ # Observer to show Popups on click
            click <- input$map_click
            if (!is.null(click)) fun_popup(r, lon = click$lng, lat = click$lat)
        })
        fun_raster(r, proxy = TRUE) # Plot the raster
    }
    print(shinyApp(ui, server, options = list(port = port)))
}
