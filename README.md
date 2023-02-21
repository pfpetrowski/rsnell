# rsnell

An R implementation for Snell scoring

Paul F. Petrowski

<pfpetrowski@gmail.com>

February 18, 2023

With thanks to AbacusBio for funding the development of this package.


## Summary

This package is an R implementation of the Snell scoring procedure originally derived by EJ Snell (1964) [1]. The scoring procedure is used to approximate the distance between ordinal values, assuming an approximately normal underlying distribution. The result are values on a continuous scale that are more amenable to conventional statistical analyses.

Tong et al [2] recognized the value in applying the Snell scoring procedure to calving ease data. Today, Interbull requires that calving ease traits are Snell transformed prior to genetic evaluation.

Practically, Snell scoring can be applied in any scenario where subjective ordinal scores have been used as measurements. Note that there must be three or more possible scores in order for the snell transformation to work. Binary scores will not work.

Chien Ho Wu (2008) [3] released an excel spreadsheet containing practical formulas and calculations to execute the snell procedure. This R package is based heavily on this excel spreadsheet. A significant difference between the R package and the spreadsheet is that while the spreadsheet uses a "rule fo thumb" to estimate boundary scores, the R package uses an analytic formula. The link to the spreadsheet appears to be broken today. A copy of the spreadsheet can be found in the `tests` directory of this repository.


## Example

Create dataset. This is copied from the original Snell paper.
``` r
data <- data.frame(
 "X-3" = c(0,6,0,0,0,2,3,0,1,2,0,5),
 "X-2" = c(0,3,0,4,0,4,4,0,2,2,0,1),
 "X-1" = c(0,1,3,1,0,3,3,1,0,2,0,1),
 "X0" = c(3,0,2,2,0,1,0,1,0,0,0,0),
 "X1" = c(3,1,2,4,2,0,1,1,1,2,4,1),
 "X2" = c(2,1,4,0,5,2,1,5,4,4,1,3),
 "X3" = c(4,0,1,1,5,0,0,4,4,0,7,1),
 row.names = as.character(1:12)
)
summary(data)
```
```
'data.frame':	12 obs. of  7 variables:
 $ X.3: num  0 6 0 0 0 2 3 0 1 2 ...
 $ X.2: num  0 3 0 4 0 4 4 0 2 2 ...
 $ X.1: num  0 1 3 1 0 3 3 1 0 2 ...
 $ X0 : num  3 0 2 2 0 1 0 1 0 0 ...
 $ X1 : num  3 1 2 4 2 0 1 1 1 2 ...
 $ X2 : num  2 1 4 0 5 2 1 5 4 4 ...
 $ X3 : num  4 0 1 1 5 0 0 4 4 0 ...
```

Perform the Snell procedure
``` r
snell(data)
```
```
       X.3        X.2        X.1         X0         X1         X2         X3 
-1.0724177  0.6118877  1.6023234  2.1867387  2.8375348  4.0129725  5.8508914 
```
The originally published scores are:
-1.1, 0.6, 1.6, 2.2, 2.8, 4.0, 5.8

The scores in the spreadsheet are:
-1.1, 0.611887716, 1.602323384 ,2.186738697, 2.837534795, 4.012972486, 5.84348144

The results are identical to those published except for at the boundary catagories. This is because `rsnell` uses an analytic method to calculate the outermost scores. The analytic method is from [2].


In the above scenario, the input data was already tabulated as counts of occurences for each score by group. Commonly, this table will need to be derived from rawdata. The `buildfreqtable` function is included in this function to facilitate such transformations. Suppose we have raw data like this:

```r
mydata <- data.frame("Groups" = rep(c("A", "B", "C", "D"), 10),
                     "Scores" = round(runif(40, 0, 5)))
```
```

Groups Scores
A	1			
B	2			
C	4			
D	0			
A	1			
B	1			
C	4			
D	1			
A	3			
B	3	

1-10 of 40 rows
```
This is a simple dataset that only contains a column of subgroup designations and a colunmn of scores, but it could contain and number of additional columns.

To convert this into a frequency table we would use:
``` r
freqtable <- buildfreqtable(data = mydata, trait = "Scores", subgroup = "Groups")
freqtable
```
```
  0 1 2 3 4 5
A	1	2	2	3	2	0
B	0	2	2	3	1	2
C	1	1	0	2	6	0
D	1	2	3	1	2	1
```

With this out of the way, it is now simple to perform the Snell scoring procedure.
``` r
snell(freqtable)
```
```
         0          1          2          3          4          5 
-1.0394872  0.7153731  1.8412364  2.7540183  4.1716475  6.1264721
```

## References

1. Snell, E. J. “A Scaling Procedure for Ordered Categorical Data.” Biometrics 20, no. 3 (September 1964): 592. https://doi.org/10.2307/2528498.
2. Tong, A. K. W., J. W. Wilton, and L. R. Schaeffer. “APPLICATION OF A SCORING PROCEDURE AND TRANSFORMATIONS TO DAIRY TYPE CLASSIFICATION AND BEEF EASE OF CALVING CATEGORICAL DATA.” Canadian Journal of Animal Science 57, no. 1 (March 1, 1977): 1–5. https://doi.org/10.4141/cjas77-001.
3. Wu, Chien-Ho. “A Note on the Computation Procedure for the Approximate Estimates of the SNELL Transformation,” 2008.


