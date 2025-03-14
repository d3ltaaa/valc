return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        -- you can do it like this with a config function
        config = function()
            require("catppuccin").setup({
                -- configurations
                flavour = "frappe", -- latte, frappe, macchiato, mocha
                background = { -- :h background
                    light = "latte",
                    dark = "mocha",
                },
                transparent_background = true, -- disables setting the background color.
                show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
                term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
                dim_inactive = {
                    enabled = false, -- dims the background color of inactive window
                    shade = "dark",
                    percentage = 0.15, -- percentage of the shade to apply to the inactive window
                },
            })
        end,
        -- or just use opts table
        opts = {
            -- configurations
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },
}
