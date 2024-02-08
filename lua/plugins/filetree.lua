-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function ()
    require('neo-tree').setup {}
  end,
  keys = function()
  local find_buffer_by_type = function(type)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local ft = vim.api.nvim_buf_get_option(buf, "filetype")
      if ft == type then return buf end
    end
    return -1
  end
  local toggle_neotree = function(toggle_command)
    if find_buffer_by_type "neo-tree" > 0 then
      require("neo-tree.command").execute { action = "close" }
    else
      toggle_command()
    end
  end

  return {
    {
      "<leader>e",
      function()
        toggle_neotree(function() require("neo-tree.command").execute { action = "focus", reveal = true, dir = vim.uv.cwd() } end)
      end,
      desc = "Toggle Explorer (cwd)",
    },
    {
      "<leader>E",
      function()
        toggle_neotree(function() require("neo-tree.command").execute { action = "focus", reveal = true } end)
      end,
      desc = "Toggle Explorer (root)",
    },
  }
end
}
