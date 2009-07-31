module ControllerHelpers 
  module Uploader
    # get us an object that represents an uploaded csv file
    def uploaded_file(path, content_type="test/csv", filename=nil)
      path = File.join(RAILS_ROOT, "features", "files", path)

      filename ||= File.basename(path)
      t = Tempfile.new(filename)
      FileUtils.copy_file(path, t.path)
      (class << t; self; end;).class_eval do
        alias local_path path
        define_method(:original_filename) { filename }
        define_method(:content_type) { content_type }
      end
      return t
    end
  end
end
