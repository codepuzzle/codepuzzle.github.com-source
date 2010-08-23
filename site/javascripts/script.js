$(document).ready(function() {

  $.browser.mobile = /(IEMobile|Windows CE|NetFront|PlayStation|PLAYSTATION|like Mac OS X|MIDP|UP\.Browser|Symbian|Nintendo|Android)/.test(navigator.userAgent);

  //

  $('div.post:first').show();
  $('div.post a.continue').click(function(e) {
    e.preventDefault();
    var current = $(this).parents('div.post');
    var next = current.next('div.post');
    if (next.size() == 0) {
      next = $('div.post:first');
    }
    if ($.browser.mobile) {
      current.hide();
      next.show();
    } else {
      current.css({ width: current.width(), position: 'absolute' });
      $('div.post:visible').hide('puff', {}, 500);
      next.css({ position: 'static' });
      next.show('slide', { direction: 'up' }, 1000);
    }
  });

  //

  if ($.browser.mobile) {
    //
  } else if ($.browser.webkit) {
    $('.eyecatcher span').hover(function() {
      $(this).delay(500).hide();
    }, function() {
      $(this).clearQueue().show();
    });
  } else {
    $('.eyecatcher a').hover(function() {
      $(this).find('span').show().css({
        visibility: 'visible',
        opacity: 0.4,
        fontSize: '40px'
      }).animate({
        opacity: 0,
        fontSize: '150px'
      }, 300, function() { $(this).hide(); });
    }, function() {});
  }

});