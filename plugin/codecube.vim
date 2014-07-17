function! CC_GetVisualSelection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, '\n')
endfunction

function! CC_ApiRequest() range
  "TODO: extend this with all the langs that codecube has support for
  let commentTypes = { "javascript": '//', "ruby": '#' }
  let apiKey = "CQhsSuOZIqkFBuuEVcPcDD18xdSJbz1b"
  let url = "http://api.codecube.io/sync-run/"
  let code = CC_GetVisualSelection()
  let escapedCode = substitute(code, '"', '\\\"', 'g')
  let textFiletype = &filetype
  let command = "curl -H 'Authorization: ".apiKey."' -d '{\"language\": \"".textFiletype."\", \"code\": \"".escapedCode."\"}' ".url
  let result = system(command)
  let lines = split(result, '\n')
  " the first 3 lines are the curl output
  let codeCubeResult = lines[3]
  let parsed = ParseJSON(codeCubeResult)

  let outputs = parsed.output
  let i = 0
  while i < len(outputs)
    let output = outputs[i]["body"]
    exec "normal! Go\<CR>".commentTypes[textFiletype]."CodeCube stdout: ".output."\<ESC>"
    let i += 1
  endwhile
endfunction
