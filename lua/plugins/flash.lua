return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  -- stylua: ignore
  keys = {
    { "<leader>sf", mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
    { "<leader>sb", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
    { "<leader>sr", mode = "o",               function() require("flash").remote() end,            desc = "remote flash" },
    { "<leader>sR", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<leader>ss", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
  },
}
