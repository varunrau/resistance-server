
class Api::SessionsController < Devise::SessionsController
  before_filter :authenticate_user!, except: [:create, :destroy]
  before_filter :ensure_params_exist
  respond_to :json

  def create
    resource = User.find_for_database_authentication email: params[:email]
    return invalid_login_attempt unless resource

    if params[:password]
      if resource.valid_password?(params[:password])
        sign_in(:user, resource, store: false)
        resource.ensure_authentication_token!
        render json: {success: true, auth_token: resource.authentication_token, email: resource.email}
        return
      end
    elsif params[:auth_token]
      if Devise.secure_compare(resource.authentication_token, params[:auth_token])
        render json: {success: true, auth_token: resource.authentication_token, email: resource.email}, status: 200
        return
      end
    end
    invalid_login_attempt
  end

  def destroy
    resource = User.find_for_database_authentication(email: params[:email][:email])
    resource.authentication_token = nil
    resource.save
    render json: {success: true}
  end

  protected
  def ensure_params_exist
    return unless params[:email].blank?
    puts params[:email]
    render json: {success: false, message: "Field missing"}, status: 422
  end

  def invalid_login_attempt
    render json: {success: false, message: "Error with your login or password"}, status: 401
  end
end
