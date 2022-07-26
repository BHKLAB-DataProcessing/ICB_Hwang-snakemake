library(GEOquery)
library(data.table)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]

# CLIN.txt
gunzip(file.path(work_dir, "GSE136961_series_matrix.txt.gz"))
clin <- getGEO(filename=file.path(work_dir, 'GSE136961_series_matrix.txt'), destdir=work_dir)
clin <- pData(clin)
colnames(clin) <- str_replace_all(colnames(clin), '\\W', '_')
write.table(clin, file=file.path(work_dir, 'CLIN.txt'), sep = "\t" , quote = FALSE , row.names = FALSE)

file.remove(file.path(work_dir, 'GPL24014.soft'))
file.remove(file.path(work_dir, 'GSE136961_series_matrix.txt'))

# EXP_TPM.tsv
expr <- read.table( file.path(work_dir, "GSE136961_TPM.tsv.gz"), stringsAsFactors=FALSE , sep="\t" , header=TRUE ) 
colnames(expr)[colnames(expr) != 'Symbol_ID'] <- unlist(lapply(colnames(expr)[colnames(expr) != 'Symbol_ID'], function(col){
  return(clin[clin$title == col, 'geo_accession'])
}))
write.table(expr, file=file.path(work_dir, 'EXP_TPM.tsv'), sep = "\t" , quote = FALSE , row.names = FALSE, col.names=TRUE)