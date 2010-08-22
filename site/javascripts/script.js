$(document).ready(function() {

  $('div.post:first').show();
  $('div.post a.continue').click(function(e) {
    e.preventDefault();
    var current = $(this).parents('div.post');
    var next = current.next('div.post');
    if (next.size() == 0) {
      next = $('div.post:first');
    }
    current.css({ width: current.width(), position: 'absolute' });
    $('div.post:visible').hide('puff', {}, 500);
    next.css({ position: 'static' });
    next.show('slide', { direction: 'up' }, 1000);
  });

});