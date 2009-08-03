function add_rule(name){
  var rule = $('p.'+name+'.pattern').clone().show().removeClass('pattern');
  $('#'+name+'s').append(rule);
  check_remove_icon_status(name);
}
function remove_rule(element,name){
  if (!$(element).hasClass('disabled')) {
    $(element).parent().remove();
    check_remove_icon_status(name);
  }
}

function check_remove_icon_status(name){
  var c = $('#'+name+'s p.'+name);
  var icon = $('#'+name+'s p.'+name+' a.moins')[0];
  if (c.size() == 1) {
    $(icon).addClass('disabled'); 
  } else { 
    $(icon).removeClass('disabled');
  }
}
