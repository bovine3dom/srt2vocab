#/bin/julia

using DataFrames, CSV

freqs = CSV.read("data/freqs/french.csv", DataFrame)
dropmissing!(freqs)

# rough estimate is that there are ~200,000 words in the French language
# we have different cases / conjugations etc. so let's normalise to 200k
FRENCH_SIZE = 200000
ratio = FRENCH_SIZE / size(freqs,1)
freqs.nth = range(1; step=ratio, length=size(freqs,1)) |> collect

# No-one agrees on CEFR vocab sizes, I'm going to say 20,000 is C2 and halve it for each level below
function cefr(n)
    if n > 20_000
        return "C2+"
    elseif n > 10_000
        return "C2"
    elseif n > 5_000
        return "C1"
    elseif n > 2_500
        return "B2"
    elseif n > 1_250
        return "B1"
    elseif n > 600
        return "A2"
    else
        return "A1"
    end
end

freqs.cefr = cefr.(freqs.nth)

# if using a list from humans,
# make sure words are as they appear in usage rather than infinitives - past participle and first person present work well

# film_words taken from srt2vocab.jl
# extract rows from freq that match words in list
freqs[freqs.word .∈ Ref(film_words), [:word, :cefr]] |> println
