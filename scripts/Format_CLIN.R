args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")

clin = cbind( read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , header=TRUE ) , NA )
rownames(clin) = clin[ , 1 ]
colnames(clin) = c( "patient" , "sex" , "age" , "primary" , "histo" , "stage" , "recist" , "response", "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os"  , "response.other.info" )

clin = clin[ , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

clin$primary = "Lung"
clin$response = Get_Response( data=clin )
clin$rna = tolower( clin$rna )

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

