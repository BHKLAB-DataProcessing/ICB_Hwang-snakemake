library(stringr)
library(tibble)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]
annot_dir <- args[3]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , header=TRUE )
rownames(clin) <- clin$geo_accession
cols <- c('geo_accession', 'Sex_ch1')
clin <- clin[, c(cols, colnames(clin)[!colnames(clin) %in% cols])]
new_cols <- c( "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os")
clin[new_cols] <- NA
clin <- clin[, c(cols, new_cols, colnames(clin)[!colnames(clin) %in% c(cols, new_cols)])]
colnames(clin)[colnames(clin) %in% cols] <- c('patient', 'sex')
clin$sex <- unlist(lapply(clin$sex, function(s){
  if(s == 'female'){
    return('F')
  }else{
    return('M')
  }
}))
clin$primary <- 'Lung'
clin$drug_type <- 'PD-1/PD-L1'
clin$rna <- 'tpm'

survival <- str_split(clin$survival_ch1, ',')
clin$pfs <- as.numeric(unlist(lapply(survival, function(s){
  return(str_extract(s[1], '\\d'))
})))
clin$os <- unlist(lapply(survival, function(s){
  if(str_trim(s[3]) == 'live'){
    return(0)
  }else{
    return(1)
  }
}))
clin$t.pfs <- unlist(lapply(survival, function(s){
  return(as.numeric(str_extract(s[2], '\\d+'))/30.5)
}))
clin$t.os <- unlist(lapply(survival, function(s){
  return(as.numeric(str_extract(s[4], '\\d+'))/30.5)
}))

clin$response = Get_Response( data=clin )

# Tissue and drug annotation
annotation_tissue <- read.csv(file=file.path(annot_dir, 'curation_tissue.csv'))
clin <- annotate_tissue(clin=clin, study='Hwang', annotation_tissue=annotation_tissue, check_histo=FALSE)

annotation_drug <- read.csv(file=file.path(annot_dir, 'curation_drug.csv'))
clin <- add_column(clin, unique_drugid='', .after='unique_tissueid')

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

