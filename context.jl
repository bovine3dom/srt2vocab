#!/bin/julia

source_file = "data/moses/OpenSubtitles.en-fr.fr.sorted"
big_context = readlines(source_file)
#source_file = "data/moses/OpenSubtitles.en-fr.fr"
#big_context = readlines(source_file)
#sort!(big_context, by=length, rev=true)
#write("data/moses/OpenSubtitles.en-fr.fr.sorted", join(big_context, "\n"))

# Take the first 5
context(word; num = 2) = Iterators.filter(x->contains(x, word), big_context) |> x -> Iterators.take(x, num) |> x -> join(x, "\n\n")

# context.(" " .* film_words .* " ") .|> println

# sorted_words = freqs[freqs.word .∈ Ref(film_words), [:word]] |> Array
# context.(" " .* sorted_words .* " ") .|> println
# sorted_words |> x -> join(x, "\n") |> println
