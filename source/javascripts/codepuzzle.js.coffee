App =
  currentLine: 0,
  currentPosition: 0,
  numOfLines: 0,

  labelCaretPercentage: ->
    if App.currentLine == 0
      p = "Top"
    else if App.currentLine == App.numOfLines
      p = "Bot"
    else
      p = "#{App.numOfLines / App.currentLine * 100}%"
    $('#caret-percentage').text p

  labelCaretPosition: ->
    $('#caret-position').text "#{App.currentLine},#{App.currentPosition}"

  initCaret: ->
    return if $('#caret').length > 0
    line = $('#vim-content').find('li:last-child code')
    text = line.text()
    lastChar = text.charAt(text.length - 1)
    fixText = text.substr(0, text.length - 1)
    line.text fixText
    caret = $("<span id='caret'>#{lastChar}</span>")
    line.append caret
    App.currentLine = App.numOfLines
    App.currentPosition = text.length
    App.labelCaretPercentage()
    App.labelCaretPosition()
    setInterval(
      -> caret.toggleClass('blink')
      500
    )

  renderNerdtreeTildes: ->
    tildePre = $('#nerdtree pre')
    num = $('#vim-content li').length * 3
    while num -= 1
      tildePre.text("#{tildePre.text()}~\n")
    $('#nerdtree').height $('#main').height()

  vimify: ->
    vimifiable = $('#vimify')
    lines = vimifiable.html().split '\n'
    debugger
    container = $('#vim-content')
    container.empty()
    i = 0
    for line in lines
      if i > 0 and i < lines.length - 1
        container.append "<li><code>#{line}</code></li>"
      i++
    vimifiable.empty()

  init: ->
    App.vimify()
    App.numOfLines = $('#vim-content li').length
    if App.numOfLines > 0
      App.initCaret()
      App.renderNerdtreeTildes()

$ ->
  App.init()
