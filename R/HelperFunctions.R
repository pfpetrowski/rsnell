build_cumprob <- function(noncumprobabilities){
  # This function builds a table of cumulative probabilities for each category.
  # It is the probability that an observation falls in a given category or any of
  # the categories below it  
  cumprobs <- apply(X = noncumprobabilities,
                    MARGIN = 1,
                    FUN = cumsum,
                    simplify = FALSE)
  # calculates the cumulative probabilities by applying the cumsum function over rows
  
  cumprob_table <- do.call(rbind, cumprobs)
  # combines the rows of the resulting matrix into a single data frame
  
  return(cumprob_table)
  
}


calc_nijplusnij1timesp <- function(observation_counts, probabilities){
  #Computing the probability that an observation falls in a category or lower,
  #Multiplied by the category probabilities. Not yet sure what this value really
  #represents
  #probabilities is the cumulative probabilities, as calculated by build_cumprob
  
  nijplusnij1 <- list()
  #Empty list
  
  for (ii in 1:(ncol(observation_counts) - 1)){
    
    x <- observation_counts[,ii]
    y <- observation_counts[,ii+1]
    
    nijplusnij1[[colnames(observation_counts)[ii]]] <- x + y
    #Store the sum of the current and next columns using the current column as the key
  }
  
  names <- names(nijplusnij1) #Store names
  
  nijplusnij1 <- do.call(cbind, nijplusnij1) #create matrix from the list of columns
  colnames(nijplusnij1) <- names #set names
  
  nijplusnij1timesp <- nijplusnij1 * probabilities[,1:(ncol(probabilities) - 1)]
  # Mulitply by the given cumulative probabilites.
  # The final column is dropped becasue the nijplusnij1 matrix has on fewer column
  
  sums <- colSums(nijplusnij1timesp) #sum columns
  
  return(sums)
  
}



equation1 <- function(Nj, Nj1, xj1, nnp){
  #Used for calculating the range of all categories other than the second to last
  
  response <-  log(Nj/(Nj1/(exp(xj1)-1) - Nj + nnp) + 1)
  
  return(response)
}

equation2 <- function(Nk1, nnp){
  # Used for calculating the range of the second to last category
  
  response <- log(Nk1/(nnp - Nk1) + 1) #Will fail if nnp = Nk1.
  
  return(response)
}





calc_ranges <- function(categorytotals, nijplusnij1timesp){
  #Compute the range between the two boundaries for the inner set of categories
  
  # Ranges are not computed for the first and last categories. 
  # I think you're basically computing the difference of the rightmost
  # boundaries of Xa & Xa-1
  
  ranges <- stats::setNames(rep(NA, length(categorytotals)-2),
                            names(categorytotals)[2:(length(categorytotals)-1)])
  # Initialize vector to store results. The vecotr is named with the same
  # names as category totals
  
  
  #Calc ranges
  for (ii in length(ranges):1){
    
    category <- names(ranges[ii]) # Get the category name that we are referring to
    if (ii == length(ranges)){ # For the last value we use equation 2
      
      Nk1 <- categorytotals[category]
      nnp <- nijplusnij1timesp[category]
      
      range <- equation2(Nk1 = Nk1, nnp = nnp)
    }
    
    else{ #If not the last value we use equation 1
      Nj <- categorytotals[category]
      Nj1 <- categorytotals[names(ranges[ii + 1])]
      nnp <- nijplusnij1timesp[category]
      
      range <- equation1(Nj = Nj, Nj1 = Nj1, xj1 = xj1, nnp = nnp)
    }
    
    xj1 <- range # xj1 for the next iteration is the result from this one
    
    ranges[ii] <- range # store the result
  }
  
  return(ranges) #Output is the range between the two boundaries for the inner set of categories
  
}




calc_boundaries <- function(ranges, categorytotals){
  # calculate the rightmost boundary for each category
  
  boundaries <- stats::setNames(rep(NA, length(categorytotals) - 1),
                                names(categorytotals)[1:(length(categorytotals) - 1)])
  # initialize a vector to store the results
  
  for (ii in 1:length(boundaries)){
    
    if (ii == 1){
      boundaries[ii] <- 0 # First boundary is set to 0
      nm1 <- 0 # nm1 set to 0
    }
    
    else{
      range <- ranges[ii - 1]
      boundary <- range + nm1 # compute boundary based on range and nm1
      boundaries[ii] <- boundary # store boundary
      nm1 <- boundary # nm1 for the next iteration is the boundary from this one
    }
  }
  
  return(boundaries)
  
}



calc_deflection <- function(noncumprobabilities){
  #Determine how far from the outer boundaries the outermost categories scores lie
  
  P <- mean(noncumprobabilities)
  
  value <- -log(1 - P)/P
  
  return(value)
}



calc_scores <- function(boundaries, noncumprobabilities, categorytotals){
  #Calculate scores for each category
  
  scores <- stats::setNames(rep(NA, length(categorytotals)),
                            names(categorytotals))
  # initialize vector to store the scores in. Names are the same as those in categorytotals
  
  for (ii in 1:length(scores)){
    
    if (ii == 1){
      boundary <- boundaries[ii]
      P <- noncumprobabilities[,ii]
      deflection <- calc_deflection(noncumprobabilities = noncumprobabilities[,ii])
      
      score <- boundary - deflection
      #For the first score we calculate the defelection before the first boundary
    }
    
    else if((ii > 1) & (ii < length(scores))){
      score <- (boundaries[ii] + boundaries[ii - 1]) / 2
      # For middle categories, the score is the midpoint of the surounding boundaries
    }
    
    else if (ii == length(scores)){
      boundary <- boundaries[ii - 1]
      
      P <- noncumprobabilities[,ii]
      deflection <- calc_deflection(noncumprobabilities = noncumprobabilities[,ii])
      
      score <- boundary + deflection
      #For the last score we calculate the defelection after the final boundary
    }
    
    scores[[ii]] <- score # store scores
    
  }
  
  return(scores)
  
}
