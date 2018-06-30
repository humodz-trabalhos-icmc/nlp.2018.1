

keywords = c(
        "indicado", "indicada", "recomendado", "recomendada",
        "utilizado", "utilizada", "destinado", "destinada")


fix.token.id <- function(token_id) {
    as.str = as.character(token_id)
    str.list = strsplit(as.str, '-')
    fixed.id = as.numeric(str.list[[1]][1])
    return (fixed.id)
}


process.file <- function(fin, fout) {
    bula = read.csv(fin, sep=' ', encoding='utf-8')
    bula$token_id = sapply(bula$token_id, fix.token.id)

    select = bula[which(bula$token %in% keywords)[1], ]
    id_doc = select$doc_id
    id_frase = select$sentence_id
    id_part = select$token_id

    wanted.words = (bula$doc_id == id_doc &
                    bula$sentence_id == id_frase &
                    bula$token_id > select$token_id)

    words = bula[wanted.words, "token"]

    para.que = paste(words, collapse=' ')

    fileConn = file(fout, encoding='utf-8')
    writeLines(para.que, fileConn)
    close(fileConn)
}


process.dir <- function(from_dir, to_dir) {
    dir.create(to_dir, showWarnings=FALSE)

    fnames = list.files(from_dir)

    for(fname in fnames) {
        no_extension = tools::file_path_sans_ext(fname)
        fin = paste0(from_dir, '/', fname)
        fout = paste0(to_dir, '/', no_extension, '.txt')
        process.file(fin, fout)
    }
}


main <- function() {
    args = commandArgs(trailingOnly=TRUE)
    options(warn=1)
    process.dir(from_dir=args[1], to_dir=args[2])
}


main()
