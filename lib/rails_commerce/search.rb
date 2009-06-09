class FrenchStemmingAnalyzer < Ferret::Analysis::Analyzer
  include Ferret::Analysis
  def initialize(stop_words = FULL_FRENCH_STOP_WORDS)
    @stop_words = stop_words
  end
  def token_stream(field, str)
    StemFilter.new(StopFilter.new(LowerCaseFilter.new(StandardTokenizer.new(str.normalize)), @stop_words), 'fr')
  end
end

module ActsAsFerret     
  module ClassMethods
    def find_id_by_contents(q, options = {}, &block)
      deprecated_options_support(options)
      aaf_index.find_id_by_contents(q.normalize, options, &block)
    end
  end
end

class String
  def normalize!
    self.gsub!(/(é|è|ê)/,'e')
    self.gsub!(/(ô|ö)/,'o')
    self.gsub!(/(û|ü|ù)/,'u')
    self.gsub!(/(â|ä|à)/,'a')
    self.gsub!(/(î|ï)/,'i')
    return self
  end

  def normalize
    self.dup.normalize!
  end
end
