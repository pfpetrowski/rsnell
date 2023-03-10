% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/buildfreqtable.R
\name{buildfreqtable}
\alias{buildfreqtable}
\title{Convert raw data to count data for use in snell function}
\usage{
buildfreqtable(data, trait, subgroup, order)
}
\arguments{
\item{data}{A data frame containing the raw data}

\item{trait}{A character string specifying the trait to be analyzed}

\item{subgroup}{A character string specifying the column containing the grouping variable}

\item{order}{A character vector specifying the order in which the categories of the trait should be placed}
}
\value{
A frequency table with the specified subgroup as the rownames, the scores of the specified trait as column names, and count as values
}
\description{
This function will be used to convert the raw data from the database to count data that can be passed into the snell function.
}
\details{
This function groups the data by the specified subgroup and trait, and counts the occurrences for each combination. It then reshapes the data into a frequency table.
}
\examples{
library(dplyr)
mydata <- data.frame("Groups" = rep(c("A", "B", "C", "D"), 10),
                    "Scores" = round(runif(40, 0, 5)))
buildfreqtable(data = mydata, trait = "Scores", subgroup = "Groups")

}
