function add_delivery_rule(name) {
  var delivery_rule = $('.' + name + '.pattern');
  delivery_rules = $('#delivery-rules');

  new_rule = '<div class="delivery-rule item_'+ false_id +'">';
    new_rule += delivery_rule.html().replace(/undefined_id/g, false_id);
  new_rule += '</div>';

  delivery_rules.append(new_rule);
  check_remove_icon_status('delivery-rule');

  rezindex();
  false_id--;
}

function remove_delivery_rule(element){
  $(element).parent().remove();
  check_remove_icon_status('delivery-rule');
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


