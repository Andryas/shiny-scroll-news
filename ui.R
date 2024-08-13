bslib::page_fixed(
    shinyjs::useShinyjs(),
    waiter::useWaiter(),
    
    shiny::div(
        style = "width: 600px; margin-left: auto; margin-right: auto;",
        scroll_ui("test")
    )
)