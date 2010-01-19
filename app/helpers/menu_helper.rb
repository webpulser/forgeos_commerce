module MenuHelper
  
  def display_menu_front(menu, options)
    unless menu.nil?
      lis = get_menu_li menu.menu_links.find_all_by_active(true), options
      content_tag :ul, lis.join , :class => options[:ul_class]
    end
  end

private
  def get_li_class(menu_link, options)
    if request.request_uri == menu_link.url && options[:li_current_class]
      options[:li_current_class]
    else
      options[:li_class]
    end
  end

  def get_menu_li(menu_links, options)
    lis = []
    menu_links.each do |menu_link|
      li_class = get_li_class menu_link, options
      li_link = link_to(menu_link.title, menu_link.url)
      children = menu_link.children.find_all_by_active(true)
      unless children.empty?
         li_link += content_tag :ul, get_menu_li(children, options).join , :class => options[:ul_class]
      end
      lis << content_tag(:li, li_link, :class => li_class )
    end
    return lis
  end

end
