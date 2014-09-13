
class Api::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    user = User.new(user_params)
    if user.save
      render json: { user: [email: user.email, auth_token: user.authentication_token] }, status: 201
      return
    else
      warden.custom_failure!
      render json: user.errors, status: 422
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :salt, :encrypted_password)
  end
end
