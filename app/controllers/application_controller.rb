class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token

  before_filter :authenticate_user_with_token!
  before_filter :authenticate_api_user!

  private
  def authenticate_user_with_token!
    email = request.headers[:email].presence
    user = email && User.find_by_email(email)

    if user && Devise.secure_compare(user.authentication_token, request.headers[:HTTP_AUTH_TOKEN])
      current_api_user = user
      sign_in user, store: false
    end
  end
end
