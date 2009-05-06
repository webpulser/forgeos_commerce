module Admin::BaseHelper
  def hide_html_elements_onload(element_ids)
    return javascript_tag("$('##{element_ids.join(",#")}').hide()")
  end 

  def link_to_effect_toggle(title,element_id,effect = :toggle_appear )
    return link_to_function(title,visual_effect(effect,element_id))
  end

  def yield_for_tools
    return if @content_for_tools.nil?
    out = content_tag('li', link_to(I18n.t('back').capitalize,:back, :class => 'back'))
    @content_for_tools.each do |content|
      out += content_tag('li', content) unless content.blank?
    end
    return out
  end

end
