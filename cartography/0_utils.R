.logger <- function(message, path) {
  write(
    x = paste0("[", format(Sys.time(), tz = "UTC"), " UTC]: ", message),
    file = path,
    append = TRUE
  )
}
