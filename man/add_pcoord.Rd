% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/add_pcoord.r
\name{add_pcoord}
\alias{add_pcoord}
\title{Principle coordinate analysis of phylogenies}
\usage{
add_pcoord(D)
}
\arguments{
\item{D}{A list with objects H, P, and HP, returned by prepare_paco_data}
}
\value{
The input list with added objects for the principal coordinates of the objects
}
\description{
Principle coordinate analysis of phylogenies
}
\note{
Internal function coordpcoa is a modified version of ape::pcoa, utilising vegan::eigenvals
}
\examples{
data(gopherlice)
library(ape)
gdist <- cophenetic(gophertree)
ldist <- cophenetic(licetree)
D <- prepare_paco_data(gdist, ldist, gl_links)
D <- add_pcoord(D)
}

