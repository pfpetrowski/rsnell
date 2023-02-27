#' Convert raw data to count data for use in snell function
#' 
#' This function will be used to convert the raw data from the database to count data that can be passed into the snell function.
#'
#' @param data A data frame containing the raw data
#' @param trait A character string specifying the trait to be analyzed
#' @param subgroup A character string specifying the column containing the grouping variable
#' @param order A character vector specifying the order in which the categories of the trait should be placed
#'
#' @return A frequency table with the specified subgroup as the rownames, the scores of the specified trait as column names, and count as values
#'
#' @details This function groups the data by the specified subgroup and trait, and counts the occurrences for each combination. It then reshapes the data into a frequency table.
#'
#' @examples
#' library(dplyr)
#' mydata <- data.frame("Groups" = rep(c("A", "B", "C", "D"), 10),
#'                     "Scores" = round(runif(40, 0, 5)))
#' buildfreqtable(data = mydata, trait = "Scores", subgroup = "Groups")
#'
#' @importFrom dplyr group_by across count %>%
#' @importFrom tidyselect all_of
#' @importFrom tidyr pivot_wider
#' @importFrom tibble column_to_rownames
#'
#' @export
buildfreqtable <- function(data, trait, subgroup, order){
  # groups the data by subgroup and trait and counts the occurrences for each combination
  # column name of the count column is changed to the specified trait

  if (!is.numeric(data[[trait]]) & missing(order)){
    warning("The trait is not numeric. Consider setting the order parameter.")
  }
  
  counts <- data %>% dplyr::group_by(dplyr::across(tidyselect::all_of(c(subgroup, trait)))) %>% dplyr::count()
  colnames(counts)[2] <- trait
  
  # reshapes the data into frequency table with the specified subgroup as index, 
  # specified trait as column names and count as values.
  # combinations of subgroup and trait that do not appear in the original data are still represented
  # with a count of 0 using values_fill=0
  freqtable <- counts %>% tidyr::pivot_wider(id_cols = subgroup,
                                             names_from = trait,
                                             values_from = "n",
                                             values_fill = 0)
  
  if (missing(order)){ # Assuming numeric scores if 
    freqtable <- as.data.frame(freqtable) %>%
      tibble::column_to_rownames(subgroup) %>%
      dplyr::select(tidyselect::all_of(as.character(sort(unique(data[, trait])))))
    #Ensure that columns are sorted in order of ascending score
    #And drop the HerdYear column
  }
  
  else{
    
    if (all(colnames(freqtable)[-1] %in% order)){
      freqtable <- as.data.frame(freqtable) %>%
        tibble::column_to_rownames(subgroup) %>%
        dplyr::select(tidyselect::all_of(order))
      # sort columns in the specified order
      # And drop the HerdYear column
    }
    
    else{
      stop("Not all categories in the trait are specified in the order")
    }
    
  }
  
  if (ncol(freqtable) <= 2){
    warning("A frequency table has been produced, but the trait does not have 3 or more categories
            and snell will fail if this table is passed.")
  }
  
  return(freqtable)
  
}
