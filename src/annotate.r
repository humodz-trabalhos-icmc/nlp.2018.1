# annotate.r INPUT_DIR OUTPUT_DIR
# reads text files from INPUT_DIR and writes annotated udpipe tables to OUTPUT_DIR

library(udpipe)


preprocess <- function(d) {
    d <- gsub(":", " ", d)
    d <- gsub(";", " % ", d);
    d <- gsub("não é indicado", " ", d)
    d <- gsub("não é indicada", " ", d)
    d <- gsub("não é recomendado", " ", d)
    d <- gsub("não é recomendada", " ", d)
    d <- gsub("não é utilizado", " ", d)
    d <- gsub("não é utilizada", " ", d)
    d <- gsub("não é destinado", " ", d)
    d <- gsub("não é destinada", " ", d)
    d <- gsub("não deve ser utilizado", " ", d)
    return (d)
}


annotate <- function(text, model) {
    text = preprocess(text)
    annotated = udpipe_annotate(model, x=text)
    table = as.data.frame(annotated)
    table$sentence = NULL
    return table
}


annotate.dir <- function(from_dir, to_dir, model, print.blank.files=TRUE) {
    dir.create(to_dir, showWarnings=FALSE, recursive=TRUE)

    fnames = list.files(from_dir)

    for(fname in fnames) {
        no_extension = tools::file_path_sans_ext(fname)
        fin = paste0(from_dir, '/', fname)
        fout = paste0(to_dir, '/', no_extension, '.csv')

        text = readLines(fin, encoding='utf-8')
        if(length(text) != 0) {
            table = annotate(text, model)
            write.table(table, file=fout)
        } else if(print.blank.files) {
            cat(fin, sep='\n')
        }
    }
}


load.model <- function(path) {
    model.filenames = list.files(path=path, pattern='*.udpipe')

    if(length(model.filenames) == 0) {
        result = udpipe_download_model(model_dir='data', language='portuguese')
        filename = result$file_model
    } else {
        filename = paste0(path, '/', model.filenames[1])
    }

    return (udpipe_load_model(filename))
}


annotate.r.main <- function(args) {
    if(length(args) != 2) {
        cat('Usage:\n')
        cat('    annotate.r INPUT_DIR OUTPUT_DIR\n')
        return()
    }

    model = load.model(path)
    annotate.dir(from_dir=args[1], to_dir=args[2], model)
}


# main(commandArgs(trailingOnly=TRUE))
