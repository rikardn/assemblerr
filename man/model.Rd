% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model.R
\name{model}
\alias{model}
\title{General model}
\usage{
model()
}
\value{
A general pharmacometric model
}
\description{
\code{model()} creates the foundation for a general pharmacometric model
}
\details{
This function creates a model object, the foundation for a general, software-agnostic description of a pharmacometric model.
The object created is an empty structure. In general, one will want to add components to the model,
then convert it to a software-specific model object and finally create the model code. The following components can be added
to a general model:
\itemize{
   \item \code{\link{parameter}}
   \item \code{\link{algebraic}}
   \item \code{\link{compartment}}
   \item \code{\link{flow}}
   \item \code{\link{observation}}
   \item \code{\link{parameter_value}}
   \item \code{\link{meta_tags}}
}
}
\examples{
m <- model()+
    observation(eff~emax*dose/(ed50+dose), type = "additive") +
    parameter("emax") +
    parameter("ed50")
}
