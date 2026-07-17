return {
  {
    "ggml-org/llama.vim",
    enabled = true,
    event = 'InsertEnter',
    init = function()
      vim.g.llama_config = {
        endpoint_fim = "http://127.0.0.1:8080/infill", show_info = 0
      }
    end,
  }
}
