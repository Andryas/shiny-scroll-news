#' @export
scroll_ui <- function(id) {
    ns <- shiny::NS(id)

    shiny::tagList(
        shiny::tags$head(
            shiny::tags$link(rel = 'stylesheet', type = 'text/css', href = 'styles.css')
        ),
        shiny::column(
            12,
            align = "center",
            shinyWidgets::searchInput(
                inputId = ns("search"),
                label = "",
                placeholder = "Search a new...",
                btnSearch = shiny::icon("magnifying-glass"),
                width = "600px"
            )
        ),
        shiny::div(
            id = "container",
            shiny::div(
                id = ns("end"),
                style = " height: 200px"
            )
        ),
        shiny::tags$script(
            shiny::HTML(
                stringr::str_interp(paste0(
                    "
                        function GetIdOnClick(element) {
                            var e = element.getAttribute('data-value');
                            Shiny.onInputChange('${ns}selected', e, {priority: 'event'});
                        };

                        $(document).ready(function () {
                            const observer = new IntersectionObserver(function (entries) {
                                if (entries[0].intersectionRatio > 0) {
                                    Shiny.setInputValue('${ns}list_end_reached', true, { priority: 'event' });
                                }
                            });

                            observer.observe(document.querySelector('#${ns}end'));
                        });
                    "
                ), list(ns = ns("")))
            )
        )
    )
}

#' @export
scroll_server <- function(id, aux) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        w_loader <- waiter::Waiter$new(
            id = ns("end"),
            html = waiter::spin_dots(),
            color = waiter::transparent(1)
        )

        page_number <- shiny::reactiveVal(1)

        shiny::observe({
            # input <- list(search = "over 4 million")

            shiny::removeUI(".container .item", multiple = TRUE)

            if (nchar(input$search) == "") {
                message("news - no search")
                data <- aux$new_data |>
                    dplyr::arrange(id)
            } else {
                message("news - with search")
                data <- aux$new_data |>
                    dplyr::mutate(
                        distance = 1 - stringdist::stringdist(
                            tolower(input$search),
                            tolower(headline),
                            method = "jw"
                        )
                    ) |>
                    dplyr::arrange(dplyr::desc(distance))
            }

            shinyjs::runjs(stringr::str_interp(
                "Shiny.setInputValue('${ns}list_end_reached', true, { priority: 'event' })",
                list(ns = ns(""))
            ))

            aux$new_data <- data
            page_number(1)
        }) |>
            shiny::bindEvent(
                input$search,
                ignoreNULL = FALSE,
                ignoreInit = TRUE
            )

        shiny::observe({
            w_loader$show()

            offset <- (page_number() - 1) * 10

            data <- aux$new_data[(offset + 1):(offset + 10), ]

            purrr::map(split(data, seq(nrow(data))), function(.x) {
                shiny::insertUI(
                    selector = paste0("#", ns("end")),
                    where = "beforeBegin",
                    ui = shiny::div(
                        class = "item",
                        shiny::a(
                            "data-value" = .x$id,
                            onclick = "GetIdOnClick(this)",
                            href = "#",
                            shiny::h5(.x$headline)
                        ),
                        shiny::p(class = "text-muted", .x$date)
                    )
                )
            })

            page_number(page_number() + 1)

            Sys.sleep(1)
            w_loader$hide()
        }) |>
            shiny::bindEvent(input$list_end_reached)

        shiny::observe({
            shiny::req(input$selected)
            message("news scroll - clicked: ", input$selected)
            aux$new_id <- as.integer(input$selected)
        })
    })
}
