bslib::page_fixed(
    shinyjs::useShinyjs(),
    waiter::useWaiter(),

    shiny::tags$head(
        shiny::tags$link(rel = 'stylesheet', type = 'text/css', href = 'styles.css')
    ),
    
    shiny::div(
        style = "width: 600px; margin-left: auto; margin-right: auto;",
        scroll_ui("test")
    )
)