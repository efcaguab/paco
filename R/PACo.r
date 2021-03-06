#' Performs PACo/procustes analysis
#' @param D a list with the data
#' @param nperm Number of permutations
#' @param seed Seed if results need to be reproduced
#' @param method The method to permute matrices with: "r0", "r1", "r2", "c0", "swap", "quasiswap", "backtrack", "tswap", "r00". See \code{\link[vegan]{commsim}} for details
#' @export
#' @examples 
#' data(gopherlice)
#' library(ape)
#' gdist <- cophenetic(gophertree)
#' ldist <- cophenetic(licetree)
#' D <- prepare_paco_data(gdist, ldist, gl_links)
#' D <- add_pcoord(D)
#' D <- PACo(D, nperm=10, seed=42, method="r0")
#' print(D$gof)
PACo <- function(D, nperm=1000, seed=NA, method="r0")
{
   method <- match.arg(method, c("r0", "r1", "r2", "r00", "c0", "swap", "tswap", "backtrack", "quasiswap"))
   if(!("H_PCo" %in% names(D))) D <- add_pcoord(D)
   proc <- vegan::procrustes(X=D$H_PCo, Y=D$P_PCo)
   Nlinks <- sum(D$HP)
   ## Goodness of fit
   m2ss <- proc$ss
   pvalue <- 0
   if(!is.na(seed)) set.seed(seed)
   # Create randomised matrices
   null_model <- vegan::nullmodel (D$HP, method)
   randomised_matrices <- simulate (null_model, nsim = nperm)
   for(n in c(1:nperm))
   {
      permuted_HP <- randomised_matrices[, , n]
      permuted_HP <- permuted_HP[rownames(D$HP),colnames(D$HP)]
      perm_D <- list(H=D$H, P=D$P, HP=permuted_HP)
      perm_paco <- add_pcoord(perm_D)
      perm_proc_ss <- vegan::procrustes(X=perm_paco$H_PCo, Y=perm_paco$P_PCo)$ss
      if(perm_proc_ss <= m2ss) pvalue <- pvalue + 1
   }
   pvalue <- pvalue / nperm
   D$proc <- proc
   D$gof <- list(p=pvalue, ss=m2ss, n=nperm)
   D$method <- method
   return(D)
}
