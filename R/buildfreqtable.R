#' Convert raw data to count data for use in snell function
#' 
#' This function will be used to convert the raw data from the database to count data that can be passed into the snell function.
#'
#' @param data A data frame containing the raw data
#' @param trait A character string specifying the trait to be analyzed
#' @param subgroup A character string specifying the column containing the grouping variable
#'
#' @return A frequency table with the specified subgroup as the rownames, the scores of the specified trait as column names, and count as values
#'
#' @details This function groups the data by the specified subgroup and trait, and counts the occurrences for each combination. It then reshapes the data into a frequency table.
#'
#' @examples
#' buildfreqtable(data = mydata, trait = "weight", subgroup = "SnellCategory")
#'
#' @export
buildfreqtable <- function(data, trait, subgroup){
  # groups the data by subgroup and trait and counts the occurrences for each combination
  # column name of the count column is changed to the specified trait
  counts <- data %>% group_by(across(all_of(c(subgroup, trait)))) %>% count()
  colnames(counts)[2] <- trait
  
  # reshapes the data into frequency table with the specified subgroup as index, 
  # specified trait as column names and count as values.
  # combinations of subgroup and trait that do not appear in the original data are still represented
  # with a count of 0 using values_fill=0
  freqtable <- counts %>% pivot_wider(id_cols = subgroup,
                                      names_from = trait,
                                      values_from = n,
                                      values_fill = 0)
  # reshapes the data into frequency table with HerdYear as index, 
  # trait as column names and count as values.
  # combinations of HerdYear and trait that do not appear in the original data are still represented
  # with a count of 0 using values_fill=0
  
  
  freqtable <- as.data.frame(freqtable) %>%
    column_to_rownames(subgroup) %>%
    select(all_of(as.character(sort(unique(data[, trait])))))
  #Ensure that columns are sorted in order of ascending score
  #And drop the HerdYear column
  
  return(freqtable)
  
}
