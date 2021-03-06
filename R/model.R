#' General model
#'
#' \code{model()} creates the foundation for a general pharmacometric model
#'
#' This function creates a model object, the foundation for a general, software-agnostic description of a pharmacometric model.
#' The object created is an empty structure. In general, one will want to add components to the model,
#' then convert it to a software-specific model object and finally create the model code. The following components can be added
#' to a general model:
#' \itemize{
#'    \item \code{\link{parameter}}
#'    \item \code{\link{algebraic}}
#'    \item \code{\link{compartment}}
#'    \item \code{\link{flow}}
#'    \item \code{\link{observation}}
#'    \item \code{\link{parameter_value}}
#'    \item \code{\link{meta_tags}}
#' }
#'
#' @return A general pharmacometric model
#' @export
#' @importFrom magrittr %>%
#' @examples
#' m <- model()+
#'     observation(eff~emax*dose/(ed50+dose), type = "additive") +
#'     parameter("emax") +
#'     parameter("ed50")
model <- function(){
  structure(list(), class = c("model", "fragment")) %>%
    add_facet("compartments", list(volume = list())) %>%
    add_facet("flows", list(from = character(), to = character(), definition = list()), name_column = F) %>%
    add_facet("parameters", list(type = character())) %>%
    add_facet("algebraics", list(definition = list())) %>%
    add_facet("observations", list(definition = list(), type = character())) %>%
    add_facet("parameter_values", list(parameter1 = character(), parameter2 = character(), type = character(), value = numeric()), name_column = F) %>%
    add_facet("meta_tags", list(value = character()))
}


#' Compartment
#'
#' Defines name and volume of compartment
#'
#' @seealso \code{\link{model}}
#' @param name Name of the compartment
#' @param volume Defintion of the compartment volume as a number, formula or declaration
#'
#' @return A compartment fragment
#' @export
#' @examples
#' # compartment with name "central" and volume Vc
#' comp1 <- compartment("central", volume = ~Vc)
compartment <- function(name, volume = 1){
  if(!is.character(name)) stop("'name' needs to be a character vector")
  volume <- arg_as_declaration(volume)
  item("compartments", name = name, volume = volume)
}

#' @export
#' @describeIn compartment Is an simple alias for compartment.
cmp <- compartment

#' Flows between compartments
#'
#' Creates a fragment describing a flow from between compartmens.
#'
#' @param from Name of the source compartment or NULL
#' @param to Name of the sink compartment or NULL
#' @param definition Declaration of the flow using the special variable A (amount in 'from' compartment) and C (concentration in 'from' compartment)
#'
#' @return A flow fragment
#' @export
#' @examples
#' f <- flow(from = "depot", to = "central", definition = ~ka*A)
flow <- function(from = NULL, to = NULL, definition){
  if(!is.character(from) && !is.character(to)) stop("'from' or/and 'to' need to be compartment names")
  definition <- arg_as_declaration(definition)
  item("flows", from = from, to = to, definition = definition)
}

#' Model parameter
#'
#' Defines name and type of a model parameter
#'
#' @param name Name of the paramter
#' @param type Model type to be used for the parameter
#'
#' @return A \code{\link{fragment}} representing a model parameter
#' @export
#' @examples
#' p <- parameter("cl", "log-normal")
parameter <- function(name, type){
  if(name!=make.names(name)) stop("'name' needs to be a valid variable name.")
  if(missing(type)){
    message("No type for the parameter '", name,"' was specified, using 'log-normal' as default.")
    type <- "log-normal"
  }
  item("parameters", name = name, type = type)
}


#' Observation model
#'
#' Defines how variables from a model relate to values in the data
#'
#' @param definition A \code{\link{declaration}} describing the measurement
#' @param type The model type used for the observation model
#' @param name The name used to identify the measurement
#'
#' @return A \code{\link{fragment}} representing an observation model
#'
#' @examples
#' # create an additive error observation model for the concentration from the "central" compartment
#' c_obs <- observation(conc~C["central"], "additive")
#'
#' # create a combined error observation model "eff" for the variable effect
#' e_obs <- observation(name = "eff", ~effect, "combined")
#' @export
observation <- function(definition, type, name = NULL){
  definition <- arg_as_declaration(definition)
  if(missing(type)) {
    message("No type for the observation model was specified, using 'additive' as a default")
    type <- "additive"
  }
  if(!is.character(type)) stop("'type' needs to be a character vector")
  if(!missing(name) && name!=make.names(name)) stop("'name' needs to be a valid variable name")
  item("observations", name = name, definition = definition, type = type)
}


#' @export
algebraic <- function(definition){
  definition <- arg_as_declaration(definition)
  if(is_anonymous(definition)) stop("'definition' needs to be named")
  item("algebraics", name = get_identifier(definition) %>% deparse(), definition = definition)
}


#' Create a new parameter_value
#'
#' @param parameter1
#' @param type
#' @param value
#' @param parameter2
#'
#' @return A parameter value fragment
#' @export
parameter_value <- function(parameter1, type, value, parameter2 = NULL){
  if(!is.character(parameter1)) stop("'parameter1' needs to be a character vector")
  if(!is.null(parameter2) && !is.character(parameter2)) stop("'parameter2' needs to be a character vector")
  item("parameter_values", parameter1 = parameter1, type = type, value = value, parameter2 = parameter2)
}
#' @export
parameter_value_table <- function(values, types){
  values %>%
    tibble::enframe(name = "parameter1") %>%
    dplyr::mutate(type = types, index = seq_len(n())) %>%
    {purrr::set_names(list(.), "parameter_values")} %>%
    structure(class = "fragment")
}

#' @export
meta_tag <- function(name, value){
  if(!is.character(name)) stop("'name' needs to be a character vector")
  item("meta_tags", name = name, value = value)
}

convert_compartments <- function(to, from) UseMethod("convert_compartments")

convert_observations <- function(to, from) UseMethod("convert_observations")

convert_parameters <- function(to, from) UseMethod("convert_parameters")

convert_algebraics <- function(to, from) UseMethod("convert_algebraics")

convert_meta_tags <- function(to, from) UseMethod("convert_meta_tags")

