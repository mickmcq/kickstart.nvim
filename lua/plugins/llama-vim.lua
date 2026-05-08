return {
  {
    "ggml-org/llama.vim",
    event = 'InsertEnter',
    init = function()
      vim.g.llama_config = {
        endpoint_fim = "http://127.0.0.1:8999/infill", show_info = 0
      }
    end,
  }
}
