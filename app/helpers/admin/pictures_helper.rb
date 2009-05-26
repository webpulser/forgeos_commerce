module Admin::PicturesHelper
  def new_admin_picture_path_with_session_information
    session_key = ActionController::Base.session_options[:key]
    admin_pictures_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
  end
end
