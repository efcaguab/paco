#' Internal fucntion of add_pcoord performing priciple coordinate analysis
#' @param D A list with objects H, P, and HP, returned by prepare_paco_data
#' @note Internal function coordpcoa is a modified version of ape::pcoa, utilising vegan::eigenvals

coordpcoa <-function (D, correction = "none", rn = NULL) 
{
    centre <- function(D, n) {
        One <- matrix(1, n, n)
        mat <- diag(n) - One/n
        mat.cen <- mat %*% D %*% mat
    }
    bstick.def <- function(n, tot.var = 1, ...) {
        res <- rev(cumsum(tot.var/n:1)/n)
        names(res) <- paste("Stick", seq(len = n), sep = "")
        return(res)
    }
    D <- as.matrix(D)
    n <- nrow(D)
    epsilon <- sqrt(.Machine$double.eps)
    if (length(rn) != 0) {
        names <- rn
    }
    else {
        names <- rownames(D)
    }
    CORRECTIONS <- c("none", "lingoes", "cailliez")
    correct <- pmatch(correction, CORRECTIONS)
    if (is.na(correct)) 
        stop("Invalid correction method")
    delta1 <- centre((-0.5 * D^2), n)
    trace <- sum(diag(delta1))
    D.eig <- eigen(delta1)
    min.eig <- min(D.eig$values)
    D.eig$values <- vegan::eigenvals(D.eig)
    zero.eig <- which(D.eig$values < epsilon)
    if (min.eig > -epsilon) {
        correct <- 1
        eig <- D.eig$values
        k <- length(which(eig > epsilon))
        rel.eig <- eig[1:k]/trace
        cum.eig <- cumsum(rel.eig)
        vectors <- sweep(D.eig$vectors[, 1:k, drop = FALSE], 2, sqrt(eig[1:k]), 
            FUN = "*")
        bs <- bstick.def(k)
        cum.bs <- cumsum(bs)
        res <- data.frame(eig[1:k], rel.eig, bs, cum.eig, cum.bs)
        colnames(res) <- c("Eigenvalues", "Relative_eig", "Broken_stick", 
            "Cumul_eig", "Cumul_br_stick")
        rownames(res) <- 1:nrow(res)
        rownames(vectors) <- names
        colnames(vectors) <- colnames(vectors, do.NULL = FALSE, 
            prefix = "Axis.")
        note <- paste("There were no negative eigenvalues. No correction was applied")
        out <- (list(correction = c(correction, correct), note = note, 
            values = res, vectors = vectors, trace = trace))
    }
    else {
        k <- n
        eig <- D.eig$values
        rel.eig <- eig/trace
        rel.eig.cor <- (eig - min.eig)/(trace - (n - 1) * min.eig)
        rel.eig.cor = c(rel.eig.cor[1:(zero.eig[1] - 1)], rel.eig.cor[(zero.eig[1] + 
            1):n], 0)
        cum.eig.cor <- cumsum(rel.eig.cor)
        k2 <- length(which(eig > epsilon))
        k3 <- length(which(rel.eig.cor > epsilon))
        vectors <- sweep(D.eig$vectors[, 1:k2], 2, sqrt(eig[1:k2]), 
            FUN = "*")
        if ((correct == 2) | (correct == 3)) {
            if (correct == 2) {
                c1 <- -min.eig
                note <- paste("Lingoes correction applied to negative eigenvalues: D' = -0.5*D^2 -", 
                  c1, ", except diagonal elements")
                D <- -0.5 * (D^2 + 2 * c1)
            }
            else if (correct == 3) {
                delta2 <- centre((-0.5 * D), n)
                upper <- cbind(matrix(0, n, n), 2 * delta1)
                lower <- cbind(-diag(n), -4 * delta2)
                sp.matrix <- rbind(upper, lower)
                c2 <- max(Re(eigen(sp.matrix, symmetric = FALSE, 
                  only.values = TRUE)$values))
                note <- paste("Cailliez correction applied to negative eigenvalues: D' = -0.5*(D +", 
                  c2, ")^2, except diagonal elements")
                D <- -0.5 * (D + c2)^2
            }
            diag(D) <- 0
            mat.cor <- centre(D, n)
            toto.cor <- eigen(mat.cor)
            trace.cor <- sum(diag(mat.cor))
            min.eig.cor <- min(toto.cor$values)
            toto.cor$values <- vegan::eigenvals(toto.cor)
            zero.eig.cor <- which((toto.cor$values < epsilon) & 
                (toto.cor$values > -epsilon))
            
            if (min.eig.cor > -epsilon) {
                eig.cor <- toto.cor$values
                rel.eig.cor <- eig.cor[1:k]/trace.cor
                cum.eig.cor <- cumsum(rel.eig.cor)
                k2 <- length(which(eig.cor > epsilon))
                vectors.cor <- sweep(toto.cor$vectors[, 1:k2], 
                  2, sqrt(eig.cor[1:k2]), FUN = "*")
                bs <- bstick.def(k2)
                bs <- c(bs, rep(0, (k - k2)))
                cum.bs <- cumsum(bs)
            }
            else {
                if (correct == 2) 
                  cat("Problem! Negative eigenvalues are still present after Lingoes", 
                    "\n")
                if (correct == 3) 
                  cat("Problem! Negative eigenvalues are still present after Cailliez", 
                    "\n")
                rel.eig.cor <- cum.eig.cor <- bs <- cum.bs <- rep(NA, 
                  n)
                vectors.cor <- matrix(NA, n, 2)
            }
            res <- data.frame(eig[1:k], eig.cor[1:k], rel.eig.cor, 
                bs, cum.eig.cor, cum.bs)
            colnames(res) <- c("Eigenvalues", "Corr_eig", "Rel_corr_eig", 
                "Broken_stick", "Cum_corr_eig", "Cum_br_stick")
            rownames(res) <- 1:nrow(res)
            rownames(vectors) <- names
            colnames(vectors) <- colnames(vectors, do.NULL = FALSE, 
                prefix = "Axis.")
            out <- (list(correction = c(correction, correct), 
                note = note, values = res, vectors = vectors, 
                trace = trace, vectors.cor = vectors.cor, trace.cor = trace.cor))
        }
        else {
            note <- "No correction was applied to the negative eigenvalues"
            bs <- bstick.def(k3)
            bs <- c(bs, rep(0, (k - k3)))
            cum.bs <- cumsum(bs)
            res <- data.frame(eig[1:k], rel.eig, rel.eig.cor, 
                bs, cum.eig.cor, cum.bs)
            colnames(res) <- c("Eigenvalues", "Relative_eig", 
                "Rel_corr_eig", "Broken_stick", "Cum_corr_eig", 
                "Cumul_br_stick")
            rownames(res) <- 1:nrow(res)
            rownames(vectors) <- names
            colnames(vectors) <- colnames(vectors, do.NULL = FALSE, 
                prefix = "Axis.")
            out <- (list(correction = c(correction, correct), 
                note = note, values = res, vectors = vectors, 
                trace = trace))
        }
    }
    class(out) <- "pcoa"
    out
}