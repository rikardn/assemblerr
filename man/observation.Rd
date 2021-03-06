% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model.R
\name{observation}
\alias{observation}
\title{Observation model}
\usage{
observation(definition, type, name = NULL)
}
\arguments{
\item{definition}{A \code{\link{declaration}} describing the measurement}

\item{type}{The model type used for the observation model}

\item{name}{The name used to identify the measurement}
}
\value{
A \code{\link{fragment}} representing an observation model
}
\description{
Defines how variables from a model relate to values in the data
}
\examples{
# create an additive error observation model for the concentration from the "central" compartment
c_obs <- observation(conc~C["central"], "additive")

# create a combined error observation model "eff" for the variable effect
e_obs <- observation(name = "eff", ~effect, "combined")
}
