App =
  caretNode: null,
  caretBlinkInterval: null,
  currentLine: 0,
  currentPosition: 0,
  numOfLines: 0,
  enableTypingEffect: false,

  labelCaretPosition: (x = App.currentPosition, y = App.currentLine) ->
    $('#caret-position').text "#{y},#{x}"

  initCaret: ->
    lineSpans = App.vimBuffer.find('li:last-child span')
    if $('.caret').length > 0
      $('.caret:not(:first)').removeClass('caret')
      App.caretNode = $('.caret').first()
    else
      App.caretNode =  lineSpans.last()
    App.caretNode.addClass('caret')
    App.currentLine = App.numOfLines
    App.currentPosition = lineSpans.length
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
      lineNode = App.vimBuffer.find("li:nth-child(#{y})")
      caretNode = lineNode.find("span:nth-child(#{x})")
      if caretNode.length == 0
        chars = lineNode.find("span")
        if relX == -1
          x = chars.length - 1
          caretNode = $(chars[x - 1])
        if relY != 0
          caretNode = chars.last()
          caretPositionJumped = chars.length
      if caretNode.length > 0
        App.currentPosition = x
        App.currentLine = y
        App.caretNode.removeClass('caret')
        App.caretNode = caretNode
        App.caretNode.addClass('caret')
        App.initCaretBlink()
        if caretPositionJumped
          App.labelCaretPosition(caretPositionJumped, y)
        else
          App.labelCaretPosition()

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
    $('#nerdtree-tildes, #main-tildes').each ->
      tildePre = $(this)
      num = 60
      while num -= 1
        tildePre.text("#{tildePre.text()}~\n")
    $('#nerdtree').height $('#main').height()

  vimify: (afterRender) ->
    vimifiable = $('#vimify')
    vimifiable.find('br').remove()
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
            lineHtml += "<span style='display: none;'>#{char}</span>"
        lineHtml = '<span>&nbsp;</span>' if lineHtml == ''
        lineNode = "<li style='display: none;'><code>#{lineHtml}</code></li>"
        App.vimBuffer.append lineNode
        App.renderTypingEffect i
      i++
    vimifiable.empty()
    # after rendering callback in queue
    if App.enableTypingEffect
      cbInterval = window.setInterval(->
          if App.vimBuffer.find('span').queue()[0] != 'inprogress'
            window.clearInterval cbInterval
            afterRender()
        , 400)
    else
      App.vimBuffer.find('li:hidden, span:hidden').show()
      afterRender()

  renderTypingEffect: (lineIdx) ->
    return unless App.enableTypingEffect
    lineNode = App.vimBuffer.find('li:last-child')
    lineNode.find('span').each (idx) ->
      caret = $(this)
      caret.delay(100).show(0, ->
        App.tmpCaret?.removeClass('caret')
        App.tmpCaret = caret
        lineNode.show() if idx == 0
        App.labelCaretPosition(idx, lineIdx)
      ).addClass('caret')

  init: ->
    App.renderNerdtreeTildes()
    App.enableTypingEffect = $.browser.webkit and (screen.width >= 480)
    App.vimify ->
      App.numOfLines = $('#vim-content li').length
      if App.numOfLines > 0
        App.initCaret()
        App.initCaretInteraction()

$ -> App.init()
