require('udpipe')

'%not in%' <- function(x,y) { !('%in%'(x,y)) }

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


annotate.file <- function(fin, fout, model) {
    text = readLines(fin, encoding='utf-8')

    if(length(text) == 0) {
        cat('BLANK FILE:', fin, '\n')
        return()
    }

    text = preprocess(text)

    annotated = udpipe_annotate(model, x=text)
    table = as.data.frame(annotated)
    table$sentence = NULL

    write.table(table, file=fout)
}


annotate.dir <- function(from_dir, to_dir, model) {
    dir.create(to_dir, showWarnings=FALSE)

    fnames = list.files(from_dir)
    already.done = list.files(to_dir)

    for(fname in fnames) {
        no_extension = tools::file_path_sans_ext(fname)

        if(paste0(no_extension, '.csv') %not in% already.done) {
            fin = paste0(from_dir, '/', fname)
            fout = paste0(to_dir, '/', no_extension, '.csv')
            annotate.file(fin, fout, model)
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


main <- function(args) {
    if(length(args) != 2) {
        cat('Usage:\n')
        cat('    annotate.r INPUT_DIR OUTPUT_DIR\n')
        return ()
    }


    model = load.model(path)
    annotate.dir(from_dir=args[1], to_dir=args[2], model)
}


main(commandArgs(trailingOnly=TRUE))
