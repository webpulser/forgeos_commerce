odd_even = 1;

function add_delivery_rule(name) {
  var delivery_rule = $('.' + name + '.pattern');
  delivery_rules = $('#delivery-rules');

  new_rule = '<div class="delivery-rule item_'+ false_id +' '+ (odd_even%2 == 0 ? '' : 'even') +'">';
    new_rule += delivery_rule.html().replace(/undefined_id/g, false_id);
  new_rule += '</div>';

  delivery_rules.append(new_rule);
  check_remove_icon_status('delivery-rule');

  rezindex();
  false_id--;
  odd_even++;
}

function remove_delivery_rule(element){
  $(element).parent().remove();
  check_remove_icon_status('delivery-rule');
}


function change_rule_for(element){

  delivery_type = element.options[element.selectedIndex].value;
  delivery_rules = $('#delivery-rules');

  delivery_rules.html('');
  
  rule = '<div class="delivery-rule item_0">'
  rule += $('.delivery-rule.'+ delivery_type +'.pattern').html().replace(/undefined_id/g, 0);
  rule += '</div>';
  
  delivery_rules.append(rule);
      
  check_remove_icon_status('delivery-rule');
  rezindex();
  false_id = -1;
  odd_even = 1;

}

function check_remove_icon_status(name){
  var c = $('#' + name + 's .' + name);
  var icon = $('#'+ name + 's .'+name+' a.red-minus')[0];
  
  if (c.size() == 1) {
    $(icon).hide();
  } else {
    $(icon).show();
  }
}

