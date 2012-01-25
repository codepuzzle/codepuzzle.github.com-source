$ ->
  line = $('#vim-content').find('li:last-child code')
  text = line.text()
  lastChar = text.charAt(text.length - 1)
  fixText = text.substr(0, text.length - 1)
  line.text fixText
  cursor = $("<span id='cursor'>#{lastChar}</span>")
  line.append cursor

  setInterval(
    -> cursor.toggleClass('blink')
    500
  )

  #

  tildePre = $('#nerdtree pre')
  num = $('#vim-content li').length * 3
  while num -= 1
    tildePre.text("#{tildePre.text()}~\n")
  $('#nerdtree').height $('#main').height()
