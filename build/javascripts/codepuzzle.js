(function() {
  var App;

  App = {
    caretNode: null,
    caretBlinkInterval: null,
    currentLine: 0,
    currentPosition: 0,
    numOfLines: 0,
    enableTypingEffect: false,
    labelCaretPosition: function(x, y) {
      if (x == null) x = App.currentPosition;
      if (y == null) y = App.currentLine;
      return $('#caret-position').text("" + y + "," + x);
    },
    initCaret: function() {
      var lineSpans;
      lineSpans = App.vimBuffer.find('li:last-child span');
      if ($('.caret').length > 0) {
        $('.caret:not(:first)').removeClass('caret');
        App.caretNode = $('.caret').first();
      } else {
        App.caretNode = lineSpans.last();
      }
      App.caretNode.addClass('caret');
      App.currentLine = App.numOfLines;
      App.currentPosition = lineSpans.length;
      App.labelCaretPosition();
      return App.initCaretBlink();
    },
    initCaretBlink: function() {
      if (App.caretBlinkInterval) window.clearInterval(App.caretBlinkInterval);
      return App.caretBlinkInterval = window.setInterval(function() {
        return App.caretNode.toggleClass('blink');
      }, 500);
    },
    moveCaretByCommand: function(command) {
      var line, x;
      line = App.vimBuffer.find("li:nth-child(" + App.currentLine + ")").text();
      if (command === 'word') {
        x = line.substring(App.currentPosition).search(/[^\w]\w/);
        if (x > -1) x += 2;
      } else if (command === 'end') {
        x = line.substring(App.currentPosition).search(/\w([^\w]|$)/);
        if (x > -1) x += 1;
      }
      if (x && x > 0) return App.moveCaret(x, 0);
    },
    moveCaret: function(relX, relY) {
      var caretNode, caretPositionJumped, chars, lineNode, x, y;
      x = App.currentPosition + relX;
      y = App.currentLine + relY;
      if ((x > 0 && y > 0) && (x !== App.currentPosition || y !== App.currentLine)) {
        lineNode = App.vimBuffer.find("li:nth-child(" + y + ")");
        caretNode = lineNode.find("span:nth-child(" + x + ")");
        if (caretNode.length === 0) {
          chars = lineNode.find("span");
          if (relX === -1) {
            x = chars.length - 1;
            caretNode = $(chars[x - 1]);
          }
          if (relY !== 0) {
            caretNode = chars.last();
            caretPositionJumped = chars.length;
          }
        }
        if (caretNode.length > 0) {
          App.currentPosition = x;
          App.currentLine = y;
          App.caretNode.removeClass('caret');
          App.caretNode = caretNode;
          App.caretNode.addClass('caret');
          App.initCaretBlink();
          if (caretPositionJumped) {
            return App.labelCaretPosition(caretPositionJumped, y);
          } else {
            return App.labelCaretPosition();
          }
        }
      }
    },
    initCaretInteraction: function() {
      var KEY_B, KEY_BACKSPACE, KEY_DOWN, KEY_E, KEY_H, KEY_J, KEY_K, KEY_L, KEY_LEFT, KEY_RIGHT, KEY_SPACE, KEY_UP, KEY_W, interactions;
      KEY_LEFT = 37;
      KEY_UP = 38;
      KEY_RIGHT = 39;
      KEY_DOWN = 40;
      KEY_H = 72;
      KEY_J = 74;
      KEY_K = 75;
      KEY_L = 76;
      KEY_W = 87;
      KEY_E = 69;
      KEY_B = 66;
      KEY_SPACE = 32;
      KEY_BACKSPACE = 8;
      interactions = {};
      interactions[KEY_LEFT] = function() {
        return App.moveCaret(-1, 0);
      };
      interactions[KEY_UP] = function() {
        return App.moveCaret(0, -1);
      };
      interactions[KEY_RIGHT] = function() {
        return App.moveCaret(1, 0);
      };
      interactions[KEY_DOWN] = function() {
        return App.moveCaret(0, 1);
      };
      interactions[KEY_SPACE] = interactions[KEY_RIGHT];
      interactions[KEY_BACKSPACE] = interactions[KEY_LEFT];
      interactions[KEY_H] = interactions[KEY_LEFT];
      interactions[KEY_J] = interactions[KEY_DOWN];
      interactions[KEY_K] = interactions[KEY_UP];
      interactions[KEY_L] = interactions[KEY_RIGHT];
      interactions[KEY_W] = function() {
        return App.moveCaretByCommand('word');
      };
      interactions[KEY_E] = function() {
        return App.moveCaretByCommand('end');
      };
      interactions[KEY_B] = function() {
        return App.moveCaretByCommand('back');
      };
      $(window).keydown(function(e) {
        try {
          return interactions[e.which || e.keyCode]();
        } catch (e) {

        }
      });
      return $(document.body).trigger('click');
    },
    renderNerdtreeTildes: function() {
      $('#nerdtree-tildes, #main-tildes').each(function() {
        var num, tildePre, _results;
        tildePre = $(this);
        num = 60;
        _results = [];
        while (num -= 1) {
          _results.push(tildePre.text("" + (tildePre.text()) + "~\n"));
        }
        return _results;
      });
      return $('#nerdtree').height($('#main').height());
    },
    vimify: function(afterRender) {
      var cbInterval, char, i, line, lineHtml, lineNode, lines, skipHtmlTag, vimifiable, _i, _j, _len, _len2, _ref;
      vimifiable = $('#vimify');
      lines = vimifiable.html().split('\n');
      App.vimBuffer = $('#vim-content');
      App.vimBuffer.empty();
      i = 0;
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        if (i > 1 && i < lines.length - 1) {
          lineHtml = '';
          skipHtmlTag = false;
          _ref = line.split('');
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            char = _ref[_j];
            if (char === '<') {
              skipHtmlTag = true;
              lineHtml += '<';
            } else if (char === '>') {
              skipHtmlTag = false;
              lineHtml += '>';
            } else if (skipHtmlTag) {
              lineHtml += char;
            } else {
              lineHtml += "<span style='display: none;'>" + char + "</span>";
            }
          }
          if (lineHtml === '') lineHtml = '<span>&nbsp;</span>';
          lineNode = "<li style='display: none;'><code>" + lineHtml + "</code></li>";
          App.vimBuffer.append(lineNode);
          App.renderTypingEffect(i);
        }
        i++;
      }
      vimifiable.empty();
      if (App.enableTypingEffect) {
        return cbInterval = window.setInterval(function() {
          if (App.vimBuffer.find('span').queue()[0] !== 'inprogress') {
            window.clearInterval(cbInterval);
            return afterRender();
          }
        }, 400);
      } else {
        App.vimBuffer.find('li:hidden, span:hidden').show();
        return afterRender();
      }
    },
    renderTypingEffect: function(lineIdx) {
      var lineNode;
      if (!App.enableTypingEffect) return;
      lineNode = App.vimBuffer.find('li:last-child');
      return lineNode.find('span').each(function(idx) {
        var caret;
        caret = $(this);
        return caret.delay(100).show(0, function() {
          var _ref;
          if ((_ref = App.tmpCaret) != null) _ref.removeClass('caret');
          App.tmpCaret = caret;
          if (idx === 0) lineNode.show();
          return App.labelCaretPosition(idx, lineIdx);
        }).addClass('caret');
      });
    },
    init: function() {
      App.renderNerdtreeTildes();
      App.enableTypingEffect = $.browser.webkit && (screen.width >= 480);
      return App.vimify(function() {
        App.numOfLines = $('#vim-content li').length;
        if (App.numOfLines > 0) {
          App.initCaret();
          return App.initCaretInteraction();
        }
      });
    }
  };

  $(function() {
    return App.init();
  });

}).call(this);
