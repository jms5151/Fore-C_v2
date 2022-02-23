library(curl)

list_ftp_files <- function(ftp_path){
  # list files
  list_files <- curl::new_handle()
  curl::handle_setopt(list_files, ftp_use_epsv = TRUE, dirlistonly = TRUE)
  con <- curl::curl(url = ftp_path, "r", handle = list_files)
  files <- readLines(con)
  close(con)
  files
}


list_and_download_ftp_files <- function(ftp_path, dest_dir){
  # list files
  list_files <- curl::new_handle()
  curl::handle_setopt(list_files, ftp_use_epsv = TRUE, dirlistonly = TRUE)
  con <- curl::curl(url = ftp_path, "r", handle = list_files)
  files <- readLines(con)
  close(con)
  # only list netcdf files, this can be removed later most likely
  files <- files[grepl('.nc', files)]
  # download files
  for(i in files){
    ftp_path_tmp <- paste0(ftp_path, i)
    dest_path <- paste0(dest_dir, i)
    curl_download(ftp_path_tmp, dest_path)
  }
}
