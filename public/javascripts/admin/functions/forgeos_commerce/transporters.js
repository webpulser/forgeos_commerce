function add_delivery_rule(name) {
  var delivery_rule = $('.' + name + '.pattern');
  delivery_rules = $('#delivery-rules');

  delivery_rules.append('<div class="delivery-rule"' + delivery_rule.html() + '</div>');
  check_remove_icon_status('delivery-rule');

  rezindex();
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


