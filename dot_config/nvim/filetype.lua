-- Map .bu files to YAML
vim.filetype.add({
  extension = {
    bu = "yaml",
    hujson = "javascript",
  },
})
