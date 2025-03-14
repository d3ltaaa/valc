return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    opts = {
        ensure_installed = {
            "norg",
            -- bunch of languages
        },
        autopairs = {
            enable = true,
        },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = true,
        },
        indent = {
            enable = true,
            disable = { "yaml" },
        },
    },
}
