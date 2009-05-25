# hacks for swfupload with CookieStore and ActiveRecordStore. Original post was:
# see http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload
#
# also need to put
# session :cookie_only => false, :only => :create
# into the controller where the files are being uploaded (change method as appropriate)
# -----------
# this goes in config/initializers/swfupload_fix.rb
#
# Slightly modified by Peter De Berdt for CookieStore and I (Joerg Battermann)
# added support for CGI::Session::ActiveRecordStore.
#
# Make sure your SWFUpload 'upload_url' variable contains you're apps session key
# as a parameter e.g. ?_abc_session=<%= u session.session_id %>
 
class CGI::Session
  alias original_initialize initialize
  def initialize(request, option = {})
    session_key = option['session_key'] || '_session_id'
    query_string = if (qs = request.env_table["QUERY_STRING"]) and qs != ""
      qs
    elsif (ru = request.env_table["REQUEST_URI"][0..-1]).include?("?")
      ru[(ru.index("?") + 1)..-1]
    end
    if query_string and query_string.include?(session_key)
      option['session_data'] = CGI.unescape(query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first)
    end
    original_initialize(request, option)
  end
end
 
class CGI::Session::ActiveRecordStore
  alias original_initialize initialize
  def initialize(session, option = nil)
    if option.include?("session_data")
      session.instance_variable_set('@session_id', option["session_data"]) unless option["session_data"].empty?
    end
    
    original_initialize(session, option)
  end
end
 
class CGI::Session::CookieStore
  alias original_initialize initialize
  def initialize(session, options = {})
    @session_data = options['session_data']
    original_initialize(session, options)
  end
 
  def read_cookie
    cookie = @session_data || @session.cgi.cookies[@cookie_options['name']].first
    return cookie if cookie
    return unless @session.cgi.request_method == "POST" # && @session.cgi.user_agent =~ /Flash Player/ This condition is commented, because of Flash user-agent differs a lot
    session_id = ActionController::CgiRequest.new(@session.cgi, ActionController::Base.session_options).request_parameters[@cookie_options['name']]
    return unless session_id
    @session.instance_variable_set('@session_id', session_id)
  end
end
