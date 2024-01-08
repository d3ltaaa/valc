return {

    {
        "nvim-neorg/neorg",
        build = ":Neorg sync-parsers",
        -- tag = "*",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("neorg").setup({
                load = {
                    ["core.defaults"] = {}, -- Loads default behaviour
                    ["core.concealer"] = {
                        config = {
                            folds = true,
                            icon_preset = "diamond",
                        },
                    }, -- Adds pretty icons to your documents
                    ["core.dirman"] = { -- Manages Neorg workspaces
                        config = {
                            workspaces = {
                                notes = "~/Notes",
                            },
                            default_workspace = "notes",
                        },
                    },
                    ["core.summary"] = {
                        config = {
                            strategy = "default",
                        },
                    },
                },
            })
        end,
    },
}
