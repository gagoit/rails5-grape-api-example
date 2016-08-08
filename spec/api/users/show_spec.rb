# encoding: utf-8
require "rails_helper"

describe "User APIs"  do
  before(:each) {
  }

  describe "GET #show" do

    context "when success" do
      before(:each) do
        @user = create :user
        @u_token = @user.user_tokens.create

        api_authorization_header(@u_token.token)
      end

      it "render user json" do
        get "/api/users/#{@user.id}", params: {}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data[:uid]).to eql @user.id
        expect(json_data[:email]).to eql @user.email
        expect(json_data[:name]).to eql @user.name
        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:success]
      end
    end

    context "when error" do
      after do
        expect(json_response[:meta][:code]).not_to eql RESPONSE_CODE[:success]
      end

      it "render unauthorized error when un-authenticated" do
        get "/api/users/1111", params: {}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data.blank?).to eql true

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:unauthorized]
        expect(json_response[:meta][:message]).to include I18n.t('errors.not_authenticated')
        # expect(json_response[:meta][:message].downcase).to include "email"
      end

      it "returns the error when user id is not found" do
        @user = create :user
        @u_token = @user.user_tokens.create

        api_authorization_header(@u_token.token)

        get "/api/users/1111", params: {}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data.blank?).to eql true
        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:not_found]
        expect(json_response[:meta][:message]).to eql I18n.t("errors.user.not_found")
      end
    end
  end
end

