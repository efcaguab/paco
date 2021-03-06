% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/paco_links.r
\name{paco_links}
\alias{paco_links}
\title{Contribution of individual links}
\usage{
paco_links(D, .parallel = FALSE, .progress = "none")
}
\arguments{
\item{D}{A list returned by proc_analysis}

\item{.parallel}{if \code{TRUE}, calculate the jacknife contribution in parallel using the backend provided by foreach}

\item{.progress}{name of the progress bar to use, see \code{\link[plyr]{create_progress_bar}}. Options include "text" and "tk". It only works when \code{.parallel = FALSE}}
}
\value{
A list with added object jacknife, containing the mean and upper CI values for each link
}
\description{
Contribution of individual links
}

