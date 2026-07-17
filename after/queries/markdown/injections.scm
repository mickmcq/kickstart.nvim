; extends

  ((fenced_code_block
    (info_string) @_lang
    (code_fence_content) @injection.content)
   (#match? @_lang "^\\{r")
   (#set! injection.language "r")) 
