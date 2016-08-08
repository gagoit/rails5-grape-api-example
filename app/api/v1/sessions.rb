module V1
  class Sessions < Grape::API
    include V1Base
    include AuthenticateRequest

    resource :sessions do

      desc 'Authenticate user and return user object / access token', http_codes: [
        { code: 200, message: 'success'},
        { code: RESPONSE_CODE[:unauthorized], message: I18n.t('errors.session.invalid') }
      ]
      params do
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User Password'
      end

      post do
        email = params[:email]
        password = params[:password]

        if email.nil? or password.nil?
          render_error(RESPONSE_CODE[:unauthorized], I18n.t('errors.session.invalid'))
          return
        end

        user = User.where(email: email.downcase).first
        if user.nil? || !user.valid_password?(password)
          render_error(RESPONSE_CODE[:unauthorized], I18n.t('errors.session.invalid'))
          return
        end

        u_token = user.login!
        serialization = UserSerializer.new(user, {show_token: true, token: u_token.token})

        render_success(serialization.as_json)
      end


      desc 'Destroy the access token', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:unauthorized], message: I18n.t('errors.session.invalid_token') }
      ]
      delete do
        authenticate!
        
        auth_token = headers['Authorization']
        user_token = UserToken.where(token: auth_token).first

        if user_token.nil?
          render_error(RESPONSE_CODE[:unauthorized], I18n.t('errors.session.invalid_token'))
          return
        else
          user_token.destroy
          render_success({})
        end
      end
    end
  end
end