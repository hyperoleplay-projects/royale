const ui_events = {}
var Loots = {}
var Next = 0
var ButtonEnabled = true

ui_events.show = function(data) {
  Loots = data.items
	initWheel(Loots)
  $('#open').removeClass('disabled')
  ButtonEnabled = true
  $('body').fadeIn(500)
}

ui_events.close = function() {
  $('body').fadeOut(500)
}

$(document).ready(function () {
  window.addEventListener("message", function (event) {
    if (event.data.action != 'points') {
    }
    if (ui_events[event.data.action]) {
      ui_events[event.data.action](event.data)
    }
  })
});

$(document).ready(function() {
 	$('#open').on('click', function(){
    if (ButtonEnabled) {
      $.post('http://duth_drop/spin', {}, (res) => {
        ButtonEnabled = false
        $('#open').addClass('disabled')
        spinWheel(parseInt(res));
      })
    }
  });
});

function initWheel(data) {
  $('.roulette-wrapper .wheel').html('')

	var $wheel = $('.roulette-wrapper .wheel'), row = "";
  var rowOrder = [ 1, 14, 2, 13, 3, 12, 4, 0, 11, 5, 10, 6, 9, 7, 8 ]

  row += "<div class='row'>";
  for (var o in rowOrder) {
    let i = rowOrder[o]
    let badgeStyle = ''

    if (data[i].badge) {
      badgeStyle = `style="border: 2px solid ${data[i].badge}b0; background: ${data[i].badge}4d"`
    }
    row += "  <div class='card' "+badgeStyle+"><img src='"+data[i].img+"'/><span>"+data[i].name+"</span><\/div>";
  }
  row += "<\/div>";

	for(var x = 0; x < 29; x++){
  	$wheel.append(row);
  }
}

function spinWheel(roll){
  var $wheel = $('.roulette-wrapper .wheel'),
  order = [0, 11, 5, 10, 6, 9, 7, 8, 1, 14, 2, 13, 3, 12, 4],
  position = order.indexOf(roll);

  var rows = 12,
  card = 182 + 3*2,
  landingPosition = (rows * 15 * card) + (position * card);

  var randomize = Math.floor(Math.random() * 182) - (182/2);

  landingPosition = landingPosition + randomize;

  var object = {
		x: Math.floor(Math.random() * 50) / 100,
    y: Math.floor(Math.random() * 20) / 100
	};

  $wheel.css({
		'transition-timing-function':'cubic-bezier(0,'+ object.x +','+ object.y + ',1)',
		'transition-duration':'6s',
		'transform':'translate3d(-'+landingPosition+'px, 0px, 0px)'
	});

  setTimeout(function(){
		$wheel.css({
			'transition-timing-function':'',
			'transition-duration':'',
		});

    var resetTo = -(position * card + randomize);
		$wheel.css('transform', 'translate3d('+resetTo+'px, 0px, 0px)');
  }, 6 * 1000);
}
