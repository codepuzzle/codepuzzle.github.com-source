App =
  caretNode: null,
  caretBlinkInterval: null,
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
    return if $('.caret').length > 0
    lineSpans = App.vimBuffer.find('li:last-child span')
    App.caretNode = lineSpans.last()
    App.caretNode.addClass('caret')
    App.currentLine = App.numOfLines
    App.currentPosition = lineSpans.length
    App.labelCaretPercentage()
    App.labelCaretPosition()
    App.initCaretBlink()

  initCaretBlink: ->
    window.clearInterval App.caretBlinkInterval if App.caretBlinkInterval
    App.caretBlinkInterval = window.setInterval(
      -> App.caretNode.toggleClass('blink')
      500
    )

  moveCaretByCommand: (command) ->
    line = App.vimBuffer.find("li:nth-child(#{App.currentLine})").text()
    if command == 'word'
      x = line.substring(App.currentPosition).search(/[^\w]\w/)
      x += 2 if x > -1
    else if command == 'end'
      x = line.substring(App.currentPosition).search(/\w([^\w]|$)/)
      x += 1 if x > -1
    #else if command == 'back'
    #  x = line.substring(0, App.currentPosition - 1).search(/[^\w]\w/)
    #  x = x - App.currentPosition if x > -1
    App.moveCaret(x, 0) if x and x > 0

  moveCaret: (relX, relY) ->
    x = App.currentPosition + relX
    y = App.currentLine + relY
    if (x > 0 and y > 0) and (x != App.currentPosition or y != App.currentLine)
      caretNode = App.vimBuffer.find("li:nth-child(#{y}) span:nth-child(#{x})")
      if relY != 0 and caretNode.length == 0
        caretNode = App.vimBuffer.find("li:nth-child(#{y}) span:last-child")
      if caretNode.length > 0
        App.currentPosition = x
        App.currentLine = y
        App.caretNode.removeClass('caret')
        App.caretNode = caretNode
        App.caretNode.addClass('caret')
        App.initCaretBlink()

  initCaretInteraction: ->
    KEY_LEFT = 37
    KEY_UP = 38
    KEY_RIGHT = 39
    KEY_DOWN = 40
    KEY_H = 72
    KEY_J = 74
    KEY_K = 75
    KEY_L = 76
    KEY_W = 87
    KEY_E = 69
    KEY_B = 66
    KEY_SPACE = 32
    KEY_BACKSPACE = 8
    interactions = {}
    interactions[KEY_LEFT] = -> App.moveCaret(-1, 0)
    interactions[KEY_UP] = -> App.moveCaret(0, -1)
    interactions[KEY_RIGHT] = -> App.moveCaret(1, 0)
    interactions[KEY_DOWN] = -> App.moveCaret(0, 1)
    interactions[KEY_SPACE] = interactions[KEY_RIGHT]
    interactions[KEY_BACKSPACE] = interactions[KEY_LEFT]
    interactions[KEY_H] = interactions[KEY_LEFT]
    interactions[KEY_J] = interactions[KEY_DOWN]
    interactions[KEY_K] = interactions[KEY_UP]
    interactions[KEY_L] = interactions[KEY_RIGHT]
    interactions[KEY_W] = -> App.moveCaretByCommand('word')
    interactions[KEY_E] = -> App.moveCaretByCommand('end')
    interactions[KEY_B] = -> App.moveCaretByCommand('back')
    $(window).keydown (e) ->
      try interactions[e.which || e.keyCode]() catch e
    $(document.body).trigger('click')

  renderNerdtreeTildes: ->
    tildePre = $('#nerdtree pre')
    num = $('#vim-content li').length * 3
    while num -= 1
      tildePre.text("#{tildePre.text()}~\n")
    $('#nerdtree').height $('#main').height()

  vimify: ->
    vimifiable = $('#vimify')
    lines = vimifiable.html().split '\n'
    App.vimBuffer = $('#vim-content')
    App.vimBuffer.empty()
    i = 0
    for line in lines
      if i > 1 and i < lines.length - 1
        lineHtml = ''
        skipHtmlTag = false
        for char in line.split ''
          if char == '<'
            skipHtmlTag = true
            lineHtml += '<'
          else if char == '>'
            skipHtmlTag = false
            lineHtml += '>'
          else if skipHtmlTag
            lineHtml += char
          else
            lineHtml += "<span>#{char}</span>"
        lineHtml = '<span>&nbsp;</span>' if lineHtml == ''
        App.vimBuffer.append "<li><code>#{lineHtml}</code></li>"
      i++
    vimifiable.empty()

  init: ->
    App.vimify()
    App.numOfLines = $('#vim-content li').length
    if App.numOfLines > 0
      App.initCaret()
      App.initCaretInteraction()
      App.renderNerdtreeTildes()

$ ->
  App.init()
