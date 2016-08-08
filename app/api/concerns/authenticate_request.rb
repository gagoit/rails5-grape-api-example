require 'api_exception'

module AuthenticateRequest
  extend ActiveSupport::Concern

  included do
    helpers do
      # Devise methods overwrites
      def current_user
        return nil if request.headers['Authorization'].blank?
        
        @current_user ||= User.by_auth_token(request.headers['Authorization'])
      end

      ##
      # Authenticate request with token of user
      ##
      def authenticate!
        raise error!({meta: {code: RESPONSE_CODE[:unauthorized], message: I18n.t("errors.not_authenticated"), debug_info: ''}}, RESPONSE_CODE[:unauthorized]) unless current_user
      end

      ##
      # 
      ##
      def authenticate_request!
        if request.headers['AccessToken'].blank?
          raise error!({meta: {code: RESPONSE_CODE[:forbidden], message: I18n.t("errors.bad_request"), debug_info: ''}}, RESPONSE_CODE[:forbidden])
        else
          
        end
      end
    end
  end


  private

end
