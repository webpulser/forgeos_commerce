module ApplicationHelper
  include CartHelper
  include WishlistHelper
  include ProductHelper
  include OrderHelper
  include CategoryHelper

  def price_with_currency(price=0, precision=2)
    price = (price * current_currency.to_exchanges_rate(Currency::default).rate) unless current_currency.default?
    number_to_currency price, :precision => precision, :unit => current_currency.html
  end

  def payment_fields_with_env(form_builder, object, method, elements)
    %w(development production).map do |env|
      content_tag(:div,
        content_tag(:h4, env.capitalize) +
        elements.map { |element| payment_field_with_env(form_builder, object, method, env, element) }.join('').html_safe, 
      :class => 'grid_7')
    end.join("\n").html_safe
  end

  def payment_field_with_env(form_builder, object, method, env, element)
    field_name = serialized_field_name(method, env, element)
    content_tag(:div, form_builder.label(field_name, t(element, :scope => [:payment, method])), :class => 'grid_3 omega') +
    content_tag(:div, form_builder.text_field(field_name, :value => (object[method].nil? ? '' : object[method][env][element])), :class => 'grid_4 alpha') +
    content_tag(:div, '', :class => 'clear')
  end

  def serialized_field(form_builder, object, type, method, element)
    field_name = serialized_field_name(method, element)
    form_builder.label field_name, t(element, :scope => [:payment, method]) +
    case type
    when :text_field
      form_builder.send(type, field_name, :value => (object[method].nil? ? '' : object[method][element]))
    when :check_box
      form_builder.send(type, field_name, :checked => (object[method] and object[method][element] == '1'))
    when :text_area
      form_builder.send(type, field_name, :value => (object[method].nil? ? '' : object[method][element]), :class => 'mceEditor')
    end
  end

  def serialized_field_name(*keys)
    keys.map(&:to_s) * ']['
  end
end
