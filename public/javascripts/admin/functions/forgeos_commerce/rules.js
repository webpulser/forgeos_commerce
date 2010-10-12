function add_rule(name){
  //alert(name);
  //var rule = $('p.'+name+'.pattern').clone().show().removeClass('pattern');
  var rule = $('p.'+name+'.pattern');
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
  var action = $('p.'+name+'.pattern');
  $('#action-conditions').append("<div class='condition'>"+action.html()+"</div>");
  //check_remove_icon_status('action-condition');
  rezindex();
  check_icons('action-conditions');
}

function change_action(element,name,type){
  var selected = $(element).val().replace(/\s+/g,"");
  var action = $(element).parent().parent();
  action.html('');
  action.append($('.action-'+selected+'-'+type+'.pattern').html());
  rezindex();
  check_icons('action-conditions');
}

function add_cart_rule(){
  $('#rule-conditions').append("<div class='condition'>"+$('.rule-Totalitemsquantity.pattern').html()+'</div>');
  check_icons('rule-conditions');
  //check_remove_icon_status('rule-condition');
}

function check_icons(type){
  if ($('#'+type).children('.condition').size() == 1){
    $('#'+type).children('.condition').children('.small-icons.red-delete-icon').hide();
  }else{
    $('#'+type).children('.condition').children('.small-icons.red-delete-icon').show();
  }
}

function change_select_for(element){
  if ($(element).val() != 'Category'){
    $('#rule_builder_target').parent().hide();
    if ($(element).val() == 'Cart'){
      $('#rule-conditions').html('');
      $('#rule-conditions').append("<div class='condition'>"+$('.rule-Totalitemsquantity.pattern').html()+'</div>');

      // then actions only => Offer a product and Offer free delivery

      $('#action-conditions').html('');
      $('#action-conditions').append("<div class='condition'>"+$('.action-1-cart.pattern').html()+'</div>');

    }
    else{
	  $('#rule-conditions').html('');
	  $('#action-conditions').html('');
	  $('#rule-conditions').append("<div class='condition'>"+$('.rule-condition.pattern').html()+'</div>');
      if ($('#rule_builder_for :selected').text() == 'Product in Cart'){
        $('#action-conditions').append("<div class='condition'>"+$('.action-0-productincart.pattern').html()+'</div>');
      } else {
        $('#action-conditions').append("<div class='condition'>"+$('.action-0-productinshop.pattern').html()+'</div>');
      }
    }
  }
  else{
    $('#rule_builder_target').parent().show();
    $('#rule-conditions').html('');
    $('#rule-conditions').append("<div class='condition'>"+$('.rule-condition.pattern').html()+'</div>');
    $('#action-conditions').html('');
    $('#action-conditions').append("<div class='condition'>"+$('.action-0-category.pattern').html()+'</div>');

  }
  rezindex();
  //check_remove_icon_status('rule-condition');
  //check_remove_icon_status('action-condition');
  check_icons('action-conditions');
  check_icons('rule-conditions');
  check_icons('end-conditions');
}
