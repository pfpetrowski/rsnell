#' Calculate Snell scores
#'
#' This function calculates Snell scores given counts of scores by subpopulation
#'
#' @param table a frequency table with group labels in rows and the original scores in columns.
#' This can be derived using the buildfreqtable function.
#' 
#' @return a vector of scores corresponding to the columns of the input frequency table.
#' 
#' @references 
#'   http://140.136.247.242/~stat2016/stat/NoteOnSnellComp.pdf
#'
#' @examples
#' library(dplyr)
#' mydata <- data.frame("Groups" = rep(c("A", "B", "C", "D"), 10),
#'                      "Scores" = round(runif(40, 0, 5)))
#' freqtable <- buildfreqtable(data = mydata, trait = "Scores", subgroup = "Groups")
#' snell(freqtable)
#'
#' @export
snell <- function(table){
  # http://140.136.247.242/~stat2016/stat/NoteOnSnellComp.pdf
  # This spreadhseet helps
  # https://abacusbio-my.sharepoint.com/:x:/g/personal/pivot_abacusbio_co_nz/EUxWTQpOehxHqVs0Tkuh0S4BLss_Efk1yEydQYfNTSD9ig?e=lQCmip
  
  if (ncol(table) <= 2){
    stop("Snell scoring does not work for binary variables. 3 or more categories are required.")
  }
  
  groups <- rownames(table) # grouping categories used by snell
  categories <- colnames(table) # score categories used 
  
  groupcounts <- rowSums(table) # count of observations in each group
  categorytotals <- colSums(table) # count of observations in each scoring category
  
  #include check that groupcounts are all non zero
  
  noncumprobabilities <- table / groupcounts
  cumprobabilities <- build_cumprob(noncumprobabilities)
  
  nijplusnij1timesp <- calc_nijplusnij1timesp(table, cumprobabilities)
  #colnames(nijplusnij1timesp) <- names(table)[1:(ncol(table) - 1)]
  
  
  ranges <- calc_ranges(categorytotals = categorytotals, nijplusnij1timesp = nijplusnij1timesp)
  # calculate ranges
  
  boundaries <- calc_boundaries(ranges = ranges, categorytotals = categorytotals)
  #calculate bundaries
  
  # calculate scores
  scores <- calc_scores(boundaries = boundaries,
                        noncumprobabilities = noncumprobabilities,
                        categorytotals = categorytotals)
  
  
  return(scores)
  
}
