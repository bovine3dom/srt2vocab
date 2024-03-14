#!/bin/julia

using DataFrames, CSV

# stream in file per line, split by space, counting each word
function freq_builder(file)
    freq = Dict{String, Int}()
    for line in eachline(file)
        for word in split(line)
            freq[word] = get(freq, word, 0) + 1
        end
    end
    return freq
end

source_file = "data/moses/OpenSubtitles.en-fr.fr"
freq = freq_builder(source_file) # takes ~30 seconds

# strip punctuation and sort by frequency
df = DataFrame(word=keys(freq)|>collect, freq=values(freq)|>collect)
df.word = replace.(df[!,:word], r"[!?.,\": ♪\[\]()*<>]" => "")
df.word = lowercase.(df.word)
df = combine(groupby(df, :word), :freq => sum => :freq)
sort!(df, :freq, rev=true)
df.nfreq = df.freq ./ sum(df.freq)

# only retain words that appear more than 100 times
#df = df[df.freq .> 100, :]

CSV.write("data/freqs/french.csv", df)
