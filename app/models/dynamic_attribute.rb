class DynamicAttribute < Attribute
  before_save :dynamic_always_true
  def dynamic_always_true
    self.dynamic = true
  end
end
