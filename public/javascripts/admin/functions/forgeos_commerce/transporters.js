check_remove_icon_status('delivery-rule');
odd_even = 1;

function add_delivery_rule(name) {
  var delivery_rule = $('.' + name + '.pattern');
  delivery_rules = $('#delivery-rules');

  new_rule = '<div id="item_'+ false_id +' " class="delivery-rule '+ (odd_even%2 == 0 ? '' : 'even') +'">';
    new_rule += delivery_rule.html().replace(/undefined_id/g, false_id);
  new_rule += '</div>';

  delivery_rules.append(new_rule);
  check_remove_icon_status('delivery-rule');

  rezindex();
  false_id--;
  odd_even++;
}

function remove_delivery_rule(element){
  rule_id = get_rails_element_id($(element).parent());

  if (rule_id > 0) {
    _delete = '<input type="hidden" id="shipping_methods_to_delete_" name="shipping_methods_to_delete[]" value="'+ rule_id +'" />'
    $('#delivery-rules').append(_delete);
  }

  $(element).parent().remove();
  check_remove_icon_status('delivery-rule');
}


function change_rule_for(element){

  delivery_type = element.options[element.selectedIndex].value;
  delivery_rules = $('#delivery-rules');

  delivery_rules.html('');
  
  rule = '<div id="item_0" class="delivery-rule">'
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
  var icon = c.find('a.red-minus:first');
  
  if (c.size() == 1) {
    $(icon).hide();
  } else {
    $(icon).show();
  }
}
