# process.r INPUT_DIR OUTPUT_DIR
# Reads udpipe annotated tables from INPUT_DIR and writes processed text to OUTPUT_DIR

keywords = c(
        "indicado", "indicada", "recomendado", "recomendada",
        "utilizado", "utilizada", "destinado", "destinada")


# Converts IDs of the form "A-B" to A
# remove.expanded.contractions should be called BEFORE this function
fix.token.id <- function(token_id) {
    as.str = as.character(token_id)
    str.list = strsplit(as.str, '-')
    fixed.id = as.numeric(str.list[[1]][1])
    return (fixed.id)
}


# Usage example:
#   sentence = c('comi', 'no', 'em', 'o', 'bar', 'do', 'de', 'o', 'zé')
#   token.ids = c('1', '2-3', '2', '3', '4', '5-6', '5', '6', '7')
#   result = remove.expanded.contractions(sentence, token.ids)
remove.expanded.contractions <- function(sentence, ids) {
    contraction.ids = ids[grep('-', ids, fixed=TRUE)]
    expanded.ids = unlist(strsplit(contraction.ids, '-', fixed=TRUE))
    unwanted.indices = match(expanded.ids, ids)
    filtered.sentence = sentence[-unwanted.indices]
    return(filtered.sentence)
}


process.annotated.table <- function(udpipe.table) {
    bula = udpipe.table
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
    return (para.que)
}


process.dir <- function(from_dir, to_dir) {
    dir.create(to_dir, showWarnings=FALSE, recursive=TRUE)

    fnames = list.files(from_dir)

    for(fname in fnames) {
        no_extension = tools::file_path_sans_ext(fname)
        fin = paste0(from_dir, '/', fname)
        fout = paste0(to_dir, '/', no_extension, '.txt')

        udpipe.table = read.csv(fin, sep=' ', encoding='utf-8')
        processed.text = process.annotated.table(udpipe.table)

        fileConn = file(fout, encoding='utf-8')
        writeLines(processed.text, fileConn)
        close(fileConn)
    }
}


main <- function(args) {
    if(length(args) != 2) {
        cat('Usage:\n')
        cat('    process.r INPUT_DIR OUTPUT_DIR\n')
        return()
    }

    process.dir(from_dir=args[1], to_dir=args[2])
}


main(commandArgs(trailingOnly=TRUE))
