using Documenter

using Waterfall

if haskey(ENV, "DOCSARGS")
    for arg in split(ENV["DOCSARGS"])
        (arg in ARGS) || push!(ARGS, arg)
    end
end

DocMeta.setdocmeta!(Waterfall, :DocTestSetup, :(using Waterfall, DataFrames); recursive=true)

# Now, generate the documentation.
makedocs(clean = true,
    modules = [Waterfall],
    format = Documenter.HTML(
        mathengine = Documenter.MathJax(),
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    sitename = "Waterfall.jl",
    authors = "Caroline L. Hughes",
    # workdir = "../",
    pages = [
        "Home" => "index.md",
    ]
)

# deploydocs(
#     repo = "https://github.com/NREL/SLiDE.git",
#     target = "build",
#     branch = "gh-pages",
#     devbranch = "docs",
#     devurl = "dev",
#     versions = ["stable" => "v^", "v#.#"],
# )