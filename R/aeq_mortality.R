#' Extract AEQ mortality from Chinook FRAM database. Refactored and
#' stripped down from the framr package written by Dan Auerbach.
#' https://github.com/FRAMverse/framr/
#'
#' @export
#'
#' @param fram_db Fram database object
#' @param run_id numeric, RunID(s) as ID or ID:ID
#' @param msp Do we use MSP expansion? Logical, default true.
#'
#' @examples
#' \dontrun{
#' fram_db |> aeq_mortality(run_id = 132)
#' }
aeq_mortality <- function(fram_db, run_id = NULL, msp = TRUE) {

  validate_fram_db(fram_db, db_type = 'full', db_species = 'CHINOOK')

  if (!is.numeric(run_id) && !is.null(run_id)) {
    validate_run_id(fram_db, run_id)
  }
  if (!is.logical(msp)) {
    cli::cli_abort("`msp` must be logical.")
  }

  if (fram_db$fram_db_species != "CHINOOK") {
    cli::cli_abort("AEQ mortality can only be used with Chinook")
  }

  if(msp){
    mortality <- fram_db |>
      msp_mortality() |>
      dplyr::select(-.data$primary_key)
  }else{
    mortality <- fram_db |>
      fetch_table("Mortality") |>
      dplyr::select(-.data$primary_key)
  }

  runid <- fram_db |>
    fetch_table("RunID") |>
    dplyr::select(.data$run_id, .data$base_period_id)

  aeq <- fram_db |>
    fetch_table("AEQ")

  terminal_fishery_flag <- fram_db |>
    fetch_table("TerminalFisheryFlag")


  aeq_mort <- mortality |>
    dplyr::left_join(runid, by = "run_id") |> # join run id
    dplyr::left_join(aeq, by = c(
      "base_period_id",
      "stock_id",
      "age",
      "time_step"
    )) |>
    dplyr::left_join(terminal_fishery_flag, by = c(
      "base_period_id",
      "fishery_id",
      "time_step"
    ))

  # apply aeq
  aeq_m <- aeq_mort |>
    dplyr::mutate(dplyr::across(
      c(
        .data$landed_catch:.data$drop_off,
        .data$msf_landed_catch:.data$msf_drop_off
      ),
      \(x) dplyr::if_else(is.na(.data$terminal_flag), x * .data$aeq, x)
    )) |>
    dplyr::arrange(.data$run_id, .data$fishery_id,
                   .data$time_step, .data$stock_id
    ) |>
    `attr<-`('species', fram_db$fram_db_species)

  if(!is.null(run_id)) {
    aeq_m |> dplyr::filter(.data$run_id %in% .env$run_id)
  } else {
    aeq_m
  }
}
