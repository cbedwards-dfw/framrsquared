% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/flag_translates.R
\name{filter_flag}
\alias{filter_flag}
\title{NA's all the information in the FisheryScalers that's not being used
e.g Flag 1 only NS Scalers will be returned}
\usage{
filter_flag(.data)
}
\arguments{
\item{.data}{Fishery Scalers table}
}
\description{
NA's all the information in the FisheryScalers that's not being used
e.g Flag 1 only NS Scalers will be returned
}
\examples{
\dontrun{ fishery_scalers_table |> filter_flag()}

}
