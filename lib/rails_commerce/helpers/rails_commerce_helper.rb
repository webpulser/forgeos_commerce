module RailsCommerce
  module RailsCommerceHelper
    def activerecord_error_list(errors)
      error_list = '<ul>'
      error_list << errors.collect do |e, m|
        "<li>#{e.humanize unless e == "base"} #{m}</li>"
      end.to_s << '</ul>'
      error_list
    end

    def display_standard_flashes(message = "There were some problems with your submission:")
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
        return
      end
      content_tag('div', flash_to_display, :class => "#{level}")
    end
  end
end