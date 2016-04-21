module DeviseIosRails
  class OauthController < DeviseController
    skip_before_action :verify_authenticity_token

    respond_to :json

    def all
      respond_with resource_class.from_oauth(resource_params, new_user_callback)
    end

    alias_method :facebook, :all
    alias_method :google,   :all

    protected

    def new_user_callback
      -> {}
    end

    private

    def resource_params
      params.require(resource_name).permit(:email, :provider, :uid, :oauth_token)
    end
  end
end
