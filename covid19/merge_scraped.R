setwd("~/git/fortuna/covid19")

extract.data = function(data.file.name){
  df = read.csv(data.file.name, stringsAsFactors = FALSE)
  
  date.string = strsplit(strsplit(data.file.name, "/")[[1]][2], "\\.")[[1]][1]
  
  df.names = tolower(names(df))
  extract.cols = c(grep("country", df.names),
                   grep("total[.]*cases", df.names),
                   grep("total[.]*deaths", df.names),
                   grep("total[.]*recovered", df.names))
  if (length(extract.cols) != 4) stop("Not all columns found.")
  df.out = df[,extract.cols]
  names(df.out) = c("country", "total.cases", "total.deaths", "total.recovered")
  
  df.out$total.cases = as.numeric(gsub(",", "", df.out$total.cases))
  df.out$total.deaths = as.numeric(gsub(",", "", df.out$total.deaths))
  df.out$total.recovered = as.numeric(gsub(",", "", df.out$total.recovered))
  
  df.out$date = date.string
  
  return(df.out)
}

data.dir = "scrape_data/"
raw.data.files = list.files(data.dir)[-(1:5)]

df.list = lapply(paste0(data.dir, raw.data.files), extract.data)
df = Reduce(rbind, df.list)

# Clean up date
df$date = as.Date(df$date, "%Y%m%d")

# Clean up country names
df$country = gsub("\\.", "", df$country)
df$country = gsub("USA \\*", "USA", df$country)

# Remove "Total" country
df = df[df$country != "Total:",]

# Save
save(df, file = "scrape_data.RData")
