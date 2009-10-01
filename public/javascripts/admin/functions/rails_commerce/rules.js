function add_rule(name){
  //alert(name)
  //var rule = $('p.'+name+'.pattern').clone().show().removeClass('pattern');
  var rule = $('p.'+name+'.pattern')
  $('#'+name+'s').append("<div class='condition'"+rule.html()+'</div>');
  //check_remove_icon_status(name);
  check_icons('rule-conditions');
  check_icons('end-conditions');
  rezindex();
}
function remove_rule(element,name){
  //if (!$(element).hasClass('disabled')) {
  //  $(element).parent().remove();
  //  check_remove_icon_status(name);
  //}
  $(element).parent().remove();
  check_icons('rule-conditions');
  check_icons('end-conditions');
  check_icons('action-conditions');
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


function add_action(name){
  var action = $('p.'+name+'.pattern')
  $('#action-conditions').append("<div class='condition'>"+action.html()+"</div>");
  //check_remove_icon_status('action-condition');
  rezindex();
  check_icons('action-conditions')
}

function change_action(element,name,type){
  var selected = $(element).val().replace(/\s+/g,"")
  var action = $(element).parent().parent()
  action.html('')
  action.append($('.action-'+selected+'-'+type+'.pattern').html())
  rezindex();
  check_icons('action-conditions')
}

function add_cart_rule(){
  $('#rule-conditions').append("<div class='condition'>"+$('.rule-Totalitemsquantity.pattern').html()+'</div>')
  check_icons('rule-conditions')
  //check_remove_icon_status('rule-condition')
}

function check_icons(type){
  if ($('#'+type).children('.condition').size() == 1){
    $('#'+type).children('.condition').children('.small-icons.red-delete-icon').hide()
  }else{
    $('#'+type).children('.condition').children('.small-icons.red-delete-icon').show()
  }
}