module Admin::BaseHelper
  def hide_html_elements_onload(element_ids)
    return javascript_tag("$('##{element_ids.join(",#")}').hide()")
  end 

  def link_to_effect_toggle(title,element_id,effect = :toggle_appear )
    return link_to_function(title,visual_effect(effect,element_id))
  end

  def yield_for_tools
    return '' unless @content_for_tools
    out = ''
    @content_for_tools.each do |content|
      out += content_tag('li', content)
    end
    return out
  end

end
