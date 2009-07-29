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
    { %w(á à â ä ã Ã Ä Â À) => 'a',
      %w(é è ê ë Ë É È Ê ) => 'e',
      %w(í ì î ï I Î Ì) => 'i',
      %w(ó ò ô ö õ Õ Ö Ô Ò) => 'o',
      %w(œ) => 'oe',
      %w(ß) => 'ss',
      %w(ú ù û ü U Û Ù) => 'u',
      %w(\s+) => ' '
    }.each do |ac,rep|
      self.gsub!(Regexp.new(ac.join('|')), rep)
    end

    return self
  end

  def normalize
    self.dup.normalize!
  end
end
