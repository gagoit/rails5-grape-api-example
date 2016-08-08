# encoding: utf-8
require "rails_helper"

describe "Session APIs", type: :request  do
  before(:each) {
    @user = create :user
    @u_token = @user.user_tokens.create
  }

  describe "DELETE #destroy" do

    context "when is successfully deleted" do
      before(:each) do
        api_authorization_header(@u_token.token)
      end

      it "render user" do
        delete "/api/sessions", params: {}, headers: request_headers

        expect(response).to have_http_status(RESPONSE_CODE[:success])
        expect(json_response[:data].blank?).to eql true
        expect(UserToken.where(token: @u_token.token).first).to eql nil

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:success]
      end
    end

    context "when has error" do
      it "render the not_authenticated error code with message when Authorization token is not set in Header" do
        delete "/api/sessions", params: {}, headers: request_headers

        json_user = json_response[:data]

        expect(json_user.blank?).to eql true

        expect(response).to have_http_status(RESPONSE_CODE[:unauthorized])

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:unauthorized]
        expect(json_response[:meta][:message]).to include I18n.t('errors.not_authenticated')
        # expect(json_response[:meta][:debug_info].downcase).to include "auth_token"
      end
    end
  end
end