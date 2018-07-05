# process.r INPUT_DIR OUTPUT_DIR
# Reads udpipe annotated tables from INPUT_DIR and writes processed text to OUTPUT_DIR


keywords = c(
        "indicado", "indicada", "recomendado", "recomendada",
        "utilizado", "utilizada", "destinado", "destinada")


# Converts IDs of the form "A-B" to A
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
# remove.expanded.contractions <- function(words, ids) {
#     contraction.ids = as.character(ids[grep('-', ids, fixed=TRUE)])
#     expanded.ids = unlist(strsplit(contraction.ids, '-', fixed=TRUE))
#     unwanted.indices = match(expanded.ids, ids)
#     return(words[-unwanted.indices])
# }

remove.expanded.contractions <- function(text) {
    unwanted = c(
        ' de a ', ' de o ', ' a a ', ' em a ', ' em o ', ' de as ',
        ' de os ', ' a as ', ' em as ', ' em os ')

    for(str in unwanted) {
        text = gsub(str, '  ', text)
    }

    return (text)
}


process.annotated.table <- function(udpipe.table) {
    bula = udpipe.table
    token_id = sapply(bula$token_id, fix.token.id)

    condition = which(bula$token %in% keywords)[1]
    select = bula[condition,]
    select_token_id = token_id[condition]

    wanted.words = (bula$doc_id == select$doc_id &
                    bula$sentence_id == select$sentence_id &
                    token_id > select_token_id)

    ids = bula[wanted.words, "token_id"]
    words = bula[wanted.words, "token"]
    # words = remove.expanded.contractions(words, ids)
    para.que = paste(words, collapse=' ')
    para.que = remove.expanded.contractions(para.que)
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


process.r.main <- function(args) {
    if(length(args) != 2) {
        cat('Usage:\n')
        cat('    process.r INPUT_DIR OUTPUT_DIR\n')
        return()
    }

    process.dir(from_dir=args[1], to_dir=args[2])
}


source('src/annotate.r')
# annotate.r.main(c('data/filtered', 'data/annotated'))
process.r.main(c('data/annotated', 'data/final'))
