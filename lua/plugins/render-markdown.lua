return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
  ft = { 'markdown', 'quarto' }, -- lazy load only for these filetypes
  opts = {
    file_types = { 'markdown', 'quarto' },
    heading = {
      enabled = true,
      sign = true,
      position = 'overlay',
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      signs = { '󰫎 ' },
      width = 'full',
      backgrounds = { 'RenderMarkdownH1Bg', 'RenderMarkdownH1Bg', 'RenderMarkdownH1Bg', 'RenderMarkdownH1Bg', 'RenderMarkdownH5Bg', 'RenderMarkdownH6Bg' },
      foregrounds = { 'RenderMarkdownH1', 'RenderMarkdownH1', 'RenderMarkdownH1', 'RenderMarkdownH1', 'RenderMarkdownH5', 'RenderMarkdownH6' },
    },
  },
}
