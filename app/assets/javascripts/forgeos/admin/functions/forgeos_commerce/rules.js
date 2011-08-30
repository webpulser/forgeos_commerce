function add_rule(name){
  //alert(name);
  //var rule = jQuery('p.'+name+'.pattern').clone().show().removeClass('pattern');
  var rule = jQuery('p.'+name+'.pattern');
  jQuery('#'+name+'s').append("<div class='condition'"+rule.html()+'</div>');
  //check_remove_icon_status(name);
  check_icons('rule-conditions');
  check_icons('end-conditions');
}
function remove_rule(element,name){
  //if (!jQuery(element).hasClass('disabled')) {
  //  jQuery(element).parent().remove();
  //  check_remove_icon_status(name);
  //}
  jQuery(element).parent().remove();
  check_icons('rule-conditions');
  check_icons('end-conditions');
  check_icons('action-conditions');
}

function check_remove_icon_status(name){
  var c = jQuery('#'+name+'s p.'+name);
  var icon = jQuery('#'+name+'s p.'+name+' a.moins')[0];
  if (c.size() == 1) {
    jQuery(icon).addClass('disabled');
  } else {
    jQuery(icon).removeClass('disabled');
  }
}


function add_action(name){
  var action = jQuery('p.'+name+'.pattern');
  jQuery('#action-conditions').append("<div class='condition'>"+action.html()+"</div>");
  //check_remove_icon_status('action-condition');
  check_icons('action-conditions');
}

function change_action(element,name,type){
  var selected = jQuery(element).val().replace(/\s+/g,"");
  var action = jQuery(element).parent().parent();
  action.html('');
  action.append(jQuery('.action-'+selected+'-'+type+'.pattern').html());
  check_icons('action-conditions');
}

function add_cart_rule(){
  jQuery('#rule-conditions').append("<div class='condition'>"+jQuery('.rule-Totalitemsquantity.pattern').html()+'</div>');
  check_icons('rule-conditions');
  //check_remove_icon_status('rule-condition');
}

function check_icons(type){
  if (jQuery('#'+type).children('.condition').size() == 1){
    jQuery('#'+type).children('.condition').children('.small-icons.red-delete-icon').hide();
  }else{
    jQuery('#'+type).children('.condition').children('.small-icons.red-delete-icon').show();
  }
}

function change_select_for(element){
  if (jQuery(element).val() != 'Category'){
    jQuery('#rule_builder_target').parent().hide();
    if (jQuery(element).val() == 'Cart'){
      jQuery('#rule-conditions').html('');
      jQuery('#rule-conditions').append("<div class='condition'>"+jQuery('.rule-Totalitemsquantity.pattern').html()+'</div>');

      // then actions only => Offer a product and Offer free delivery

      jQuery('#action-conditions').html('');
      jQuery('#action-conditions').append("<div class='condition'>"+jQuery('.action-1-cart.pattern').html()+'</div>');

    }
    else{
	  jQuery('#rule-conditions').html('');
	  jQuery('#action-conditions').html('');
	  jQuery('#rule-conditions').append("<div class='condition'>"+jQuery('.rule-condition.pattern').html()+'</div>');
      if (jQuery('#rule_builder_for :selected').text() == 'Product in Cart'){
        jQuery('#action-conditions').append("<div class='condition'>"+jQuery('.action-0-productincart.pattern').html()+'</div>');
      } else {
        jQuery('#action-conditions').append("<div class='condition'>"+jQuery('.action-0-productinshop.pattern').html()+'</div>');
      }
    }
  }
  else{
    jQuery('#rule_builder_target').parent().show();
    jQuery('#rule-conditions').html('');
    jQuery('#rule-conditions').append("<div class='condition'>"+jQuery('.rule-condition.pattern').html()+'</div>');
    jQuery('#action-conditions').html('');
    jQuery('#action-conditions').append("<div class='condition'>"+jQuery('.action-0-category.pattern').html()+'</div>');

  }
  //check_remove_icon_status('rule-condition');
  //check_remove_icon_status('action-condition');
  check_icons('action-conditions');
  check_icons('rule-conditions');
  check_icons('end-conditions');
}
