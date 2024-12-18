using Jinkies
using Documenter

DocMeta.setdocmeta!(Jinkies, :DocTestSetup, :(using Jinkies); recursive=true)

makedocs(;
    modules=[Jinkies],
    authors="TheCedarPrince <jacobszelko@gmail.com> and contributors",
    sitename="Jinkies.jl",
    format=Documenter.HTML(;
        canonical="https://TheCedarPrince.github.io/Jinkies.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/TheCedarPrince/Jinkies.jl",
    devbranch="main",
)
