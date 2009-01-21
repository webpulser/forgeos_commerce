class RailsCommerceException < Exception
  attr_accessor :message, :message_code

  def initialize(options={})
    super(self.message)

    initialize_messages
    envoie_mail(options)
    set_backtrace("")
  end
  
protected
  def envoie_mail(options={})
    if options[:code] >= 100 && options[:code] < 200
      self.message = "#{options[:code]} - #{options[:class_name]} n'est pas instanciable"
      self.message += self.message_code[options[:code]] if self.message_code[options[:code]]
    end
  end

  def initialize_messages
    self.message_code = []
    # TODO - Instancier ces messages à partir d'une table en BDD.
    self.message_code[101] = "\n Classes Product non instanciable :\n * ProductParent\n * ProductDetail\n\n"
    self.message_code[102] = ""
    self.message_code[103] = ""
  end
end
