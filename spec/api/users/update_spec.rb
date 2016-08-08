# encoding: utf-8
require "rails_helper"

describe "User APIs"  do
  describe "PUT #update" do
    before(:each) do
      @user = create :user
      @user_attributes = FactoryGirl.attributes_for :user
    end

    context "when was updated successfully" do
      before(:each) do
        @u_token = @user.user_tokens.create
        api_authorization_header(@u_token.token)
      end

      after do
        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:success]
      end

      it "render the updated user json" do
        put "/api/users/#{@user.id}", params: @user_attributes.to_json, headers: request_headers

        @user.reload
        expect(@user.email).to eql @user_attributes[:email]
        expect(@user.valid_password?(@user_attributes[:password])).to eql true

        json_data = json_response[:data]
        expect(json_data[:email]).to eql @user_attributes[:email]
      end
    end

    context "when has error" do
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

      it "render unprocessable_entity error when email is missing" do
        @u_token = @user.user_tokens.create
        api_authorization_header(@u_token.token)

        @user_attributes[:email] = ""
        put "/api/users/#{@user.id}", params: @user_attributes.to_json, headers: request_headers

        @user.reload
        expect(@user.email).not_to eql @user_attributes[:email]

        json_data = json_response[:data]
        expect(json_data.blank?).to eql true

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:unprocessable_entity]
        expect(json_response[:meta][:message].downcase).to include "email"
      end

      it "render the forbidden error when update info of other user" do
        @u_token = @user.user_tokens.create
        api_authorization_header(@u_token.token)

        @user1 = create :user

        put "/api/users/#{@user1.id}", params: @user_attributes.to_json, headers: request_headers

        @user1.reload
        expect(@user1.email).not_to eql(@user_attributes[:email])

        json_data = json_response[:data]
        expect(json_data.blank?).to eql true

        expect(response).to have_http_status(RESPONSE_CODE[:forbidden])

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:forbidden]
        expect(json_response[:meta][:message]).to include I18n.t('errors.forbidden')
      end
    end
  end
end