# Plotting helper functions -------

#' Latex labeller
#' 
#' Latex labeller for ggplot that will interpret latex equations correctly (i.e. anything between $$). 
#' Works for both the \code{labels} parameter of discrete ggplot2 scales as well as the \code{labeller} of facets.
latex_labeller <- function(labels, ...) {
  
  require("dplyr")
  require("tidyr")
  require("purrr")
  require("latex2exp")
  
  # figure out if we're in a scale or facet labeller
  facet_labels <- is(labels, "data.frame")
  if (!facet_labels) labels <- data_frame(..x.. = as.character(labels))
  
  # gather labels
  labels <- labels %>% 
    # add position info
    mutate(pos = row_number()) %>% 
    # gather labels
    mutate_if(is.factor, as.character) %>% 
    gather(var, val, -pos) %>% as_data_frame() 
  
  # convert latex to expression
  labels <- labels %>% 
    mutate(
      val = map(val, ~latex2exp::TeX(.x))
    )
  
  # spread data frame again
  labels <- labels %>% 
    filter(!is.na(pos)) %>% 
    spread(var, val) %>% 
    select(-pos)
  
  # return appropriate value for labeller
  if (facet_labels) return(labels)
  else return(labels$..x..)
}
class(latex_labeller) <- c("function", "labeller")
