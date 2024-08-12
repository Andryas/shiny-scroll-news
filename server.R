shinyServer(function(input, output, session) {
    aux <- shiny::reactiveValues(
        new_data = readRDS("data/data.rds"),
        new_id = NULL
    )

    scroll_server("test", aux)
})
