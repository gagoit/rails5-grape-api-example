# encoding: utf-8
require "rails_helper"

describe "Session APIs"  do
  describe "POST #create" do
    before(:each) do
      @user_attributes = FactoryGirl.attributes_for :user
      @user = create :user, @user_attributes
    end

    context "when is successfully created" do

      it "render user json" do
        post "/api/sessions", params: {email: @user.email, password: @user_attributes[:password]}.to_json, headers: request_headers

        json_user = json_response[:data]

        expect(json_user[:uid]).to eql @user.id
        expect(json_user[:email]).to eql @user.email

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:success]
      end
    end

    context "when has error" do
      it "render unauthorized error when email and password doesn't match" do
        post "/api/sessions", params: {email: @user.email, password: "12"}.to_json, headers: request_headers

        json_user = json_response[:data]

        expect(json_user.blank?).to eql true

        expect(response).to have_http_status(RESPONSE_CODE[:unauthorized])

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:unauthorized]
        expect(json_response[:meta][:message]).to include I18n.t('errors.session.invalid')
        # expect(json_response[:meta][:debug_info].downcase).to include "session_invalid"
      end
    end
  end
end