#!/bin/julia
using DataFrames, CSV

sub_file = "SUBTITLE FILE GOES HERE"
freqs = CSV.read("data/freqs/french.csv", DataFrame)

subs = Iterators.filter(startswith(r"[^0-9]"), eachline(sub_file)) |> collect

# i should merge this with the other one but whatever
# counting each word
function freq_builder(lines)
    freq = Dict{String, Int}()
    for line in lines
        for word in split(line)
            freq[word] = get(freq, word, 0) + 1
        end
    end
    return freq
end
film_freq = freq_builder(subs)

# strip punctuation and sort by frequency
df = DataFrame(word=keys(film_freq)|>collect, freq=values(film_freq)|>collect)
df.word = replace.(df[!,:word], r"<.*>" => "")
df.word = replace.(df[!,:word], r"[!?.,\": ♪\[\]()*<>]" => "")
# should maybe cut out words in * because they're usually describing noises
df.word = replace.(df[!,:word], r"^-" => "")
df.word = lowercase.(df.word)
df.word = replace.(df[!,:word], r"^[mjstld]'" => "")
df = combine(groupby(df, :word), :freq => sum => :freq)
sort!(df, :freq, rev=true)
df.nfreq = df.freq ./ sum(df.freq)

df = leftjoin(df, freqs, on=:word, matchmissing=:notequal, makeunique=true, renamecols="_film"=>"_global")
dropmissing!(df)

df.weirdness = abs.(log.(df.nfreq_film ./ df.nfreq_global))
sort!(df, :weirdness, rev=true)


using ImageMorphology: dilate # this is hitting a fly with a rocket launcher
context(word) = begin # nb: accepts regex too
    sentences = subs[dilate(contains.(subs, word))]
    # join every three sentences together
    sentences = [join(sentences[i:i+2], " ") for i in 1:3:length(sentences)-2]
end

# Workflow
# get common words
df[df.freq_film .> 3, :][1:50, :] |> print
# copy-paste here
# delete ones that are names etc
# translate ones that seem interesting with https://www.wordreference.com/fren/
# use context() on ones that are harder
