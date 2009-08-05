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

function change_rule(element, name){
  $(element).parent().replaceWith($('.rule-'+$(element).val().replace(/\s+/g,"")+'.pattern').clone().removeClass('pattern').removeClass('rule-'+$(element).val().replace(/\s+/g,"")).addClass('rule-condition'))
  check_remove_icon_status(name);
}

function change_select_for(element){
  if ($(element).val() != 'Category'){
    $('#rule_builder_target').hide()
  }
  else{
    $('#rule_builder_target').show()
  }
}

function change_action(element, name){
  $(element).parent().replaceWith($('.action-'+$(element).val().replace(/\s+/g,"")+'.pattern').clone().removeClass('pattern').removeClass('action-'+$(element).val().replace(/\s+/g,"")).addClass('action-condition'))
  check_remove_icon_status(name);
}
