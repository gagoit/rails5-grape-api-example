module V1
  class Users < Grape::API
    include V1Base
    include AuthenticateRequest
    include UserBase

    VALID_PARAMS = %w(name email password password_confirmation)

    helpers do
      def user_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    resource :users do

      desc 'Create new user', http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' }
      ]
      params do
        requires :name, type: String, desc: 'User name'
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User Password'
        requires :password_confirmation, type: String, desc: 'User Password'
      end
      post do
        user = User.new(user_params)
        if user.save
          u_token = user.login!

          serialization = UserSerializer.new(user, {show_token: true, token: u_token.token})
          render_success(serialization.as_json)
        else
          error = user.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end


      desc 'Update user', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
        { code: RESPONSE_CODE[:unprocessable_entity], message: 'Validation error messages' },
        { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
      ]
      params do
        requires :id, type: String, desc: 'User id'
        optional :email, type: String, desc: 'User email'
        optional :password, type: String, desc: 'User Password'
        optional :password_confirmation, type: String, desc: 'User Password'

        optional :name, type: String, desc: 'User name'
      end
      put ':id' do
        authenticate!
        can_update_user?(params[:id])

        if current_user.update_attributes(user_params)
          current_user.reload

          serialization = UserSerializer.new(current_user, {show_token: false})
          render_success(serialization.as_json)
        else
          error = current_user.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end

      desc 'Get user', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
      ]
      params do
        requires :id, type: String, desc: 'User id'
      end
      get ':id' do
        authenticate!
        get_user(params[:id])

        serialization = UserSerializer.new(@user, {show_token: false})
        render_success(serialization.as_json)
      end


      desc 'Get users', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
      ]
      params do
        optional :page, type: Integer, desc: 'page'
        optional :per_page, type: Integer, desc: 'per_page'
      end
      get do
        authenticate!

        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || PER_PAGE).to_i 
        users = User.order("created_at DESC").page(page).per(per_page)

        serialization = ActiveModel::Serializer::CollectionSerializer.new(users, each_serializer: UserSerializer, show_token: false)

        render_success({users: serialization.as_json}, pagination_dict(users))
      end
    end
  end
end