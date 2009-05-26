module Admin::BaseHelper
  def hide_html_elements_onload(element_ids)
    return javascript_tag("$('##{element_ids.join(",#")}').hide()")
  end 

  def link_to_effect_toggle(title,element_id,effect = :toggle_appear )
    return link_to_function(title,visual_effect(effect,element_id))
  end

  def yield_for_tools
    content_for :tools, link_to(I18n.t('back').capitalize,:back, :class => 'back')
    out = ''
    @content_for_tools.each do |content|
      out += content_tag('li', content) unless content.blank?
    end
    return out
  end

  def display_standard_flashes(message = nil, with_tag = true)
    if !flash[:notice].nil? && !flash[:notice].blank?
      flash_to_display, level = flash[:notice], 'notice'
      flash[:notice] = nil
    elsif !flash[:warning].nil? && !flash[:warning].blank?
      flash_to_display, level = flash[:warning], 'warning'
      flash[:warning] = nil
    elsif !flash[:error].nil? && !flash[:error].blank?
      level = 'error'
      if flash[:error].instance_of? ActiveRecord::Errors
        flash_to_display = '<span class="ico close">' + message + '</span>'
        flash_to_display << activerecord_error_list(flash[:error])
      else
        flash_to_display = '<span class="ico close">' + flash[:error] + '</span>'
      end
      flash[:error] = nil
    else
      return if message.nil?
      flash_to_display = message
      level = 'notice'
    end

    script = render(:update) do |page|
      page.replace_html('display_standard_flashes', content_tag('div', flash_to_display, :class => "#{level}"))
      page.visual_effect(:slide_down, 'display_standard_flashes')
      page.delay(10) do
        page.visual_effect(:slide_up,'display_standard_flashes')
      end
    end
    return with_tag ? javascript_tag(script) : script
  end
end
