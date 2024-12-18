using JINX
using Documenter

DocMeta.setdocmeta!(JINX, :DocTestSetup, :(using JINX); recursive=true)

makedocs(;
    modules=[JINX],
    authors="TheCedarPrince <jacobszelko@gmail.com> and contributors",
    sitename="JINX.jl",
    format=Documenter.HTML(;
        canonical="https://TheCedarPrince.github.io/JINX.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/TheCedarPrince/JINX.jl",
    devbranch="main",
)
