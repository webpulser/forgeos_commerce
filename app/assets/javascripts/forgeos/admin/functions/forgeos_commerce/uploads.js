function add_picture_to_product(data){
  var object_name = jQuery('form#wrap').data('object_name');
  jQuery('#product-images ul.sortable li.clear').before('<li><a href="#" onclick="jQuery(this).parents(\'li\').remove(); check_product_first_image(); return false;" class="big-icons trash"></a><a href="/admin/pictures/' + data.id + '/edit" onclick ="window.open(this.href); return false;" class="big-icons edit" href="#"></a><input type="hidden" name="' + object_name + '[attachment_ids][]" value="' + data.id + '"/><img src="' + data.path + '" alt="' + data.name + '"/><div class="handler"><div class="inner"></div></div></li>');
  check_product_first_image();
}

function add_attachment_to_product(data){
  var object_name = jQuery('form#wrap').data('object_name');
  jQuery('#product-files').append('<div class="block-container"><input type="hidden" name="' + object_name + '[attachment_ids][]" value="' + data.id + '" /><span class="block-type"><span class="handler"><span class="inner">&nbsp;</span></span>' + data.type + '</span><span class="block-name">' + data.name + '<span class="file-size"> - ' + data.size + '</span></span><a href="/admin/' + data.type.toLowerCase() + 's/' + data.id + '/edit" onclick ="window.open(this.href); return false;" class="small-icons edit-link"></a><a href="#" class="big-icons gray-destroy"></a></div>');
}
