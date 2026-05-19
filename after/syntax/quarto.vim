" This command is for illustration and should be placed in `after/syntax/quarto.vim`

" Define a syntax region for an executable code chunk
syn region quartoExecCode start="^```{" end="^```" contains=quartoCodeOptions,quartoCodeContent

" Highlight Quarto code block options inside the region
syn match quartoCodeOptions contained "#|"
syn match SpecialComment contained "#|"

hi quartoCodeOptions cterm=underline
hi SpecialComment cterm=underline

" Quarto shortcodes like {{< include file.md >}}
syn match quartoShortcodeDelim "{{<\|>}}"
syn match quartoShortcodeName  "{{<\s*\zs\w\+"
syn match quartoShortcodeArg   "\({{<\s*\w\+\s\+\)\@<=\f\+\ze\s*>}}"

hi default link quartoShortcodeDelim Delimiter
hi default link quartoShortcodeName  Function
hi default link quartoShortcodeArg   String
