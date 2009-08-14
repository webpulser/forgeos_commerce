class Rule < ActiveRecord::Base
  acts_as_tree
  before_save :usage
  serialize :variables

  def usage
    activated = false if max_use && max_use > 0 && use >= max_use
  end
end
