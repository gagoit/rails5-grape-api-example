module UserBase
  extend ActiveSupport::Concern

  included do

    helpers do
      def get_user(id)
        @user = User.find(id)

        unless @user
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found], 
            code: RESPONSE_CODE[:not_found], 
            message: I18n.t('errors.user.not_found')
          )
        end
      end

      def can_update_user?(id)
        unless current_user.id.to_s == params[:id]
          raise ApiException.new(
            http_status: RESPONSE_CODE[:forbidden], 
            code: RESPONSE_CODE[:forbidden], 
            message: I18n.t('errors.forbidden')
          )
        end
      end
    end
  end
end