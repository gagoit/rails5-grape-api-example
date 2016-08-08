# encoding: utf-8
require "rails_helper"

describe "User APIs"  do
  before(:each) {
    @user_attributes = FactoryGirl.attributes_for :user
  }

  describe "POST #create" do

    context "when is successfully created" do
      after do
        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:success]
      end

      it "render created user" do
        post "/api/users", params: @user_attributes.to_json, headers: request_headers

        json_data = json_response[:data]

        expect(json_data[:email]).to eql @user_attributes[:email]
      end
    end

    context "when has error" do
      it "render unprocessable_entity error when email is missing" do
        @user_attributes[:email] = ""
        post "/api/users", params: @user_attributes.to_json, headers: request_headers

        json_data = json_response[:data]

        expect(json_data.blank?).to eql true

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:unprocessable_entity]
        expect(json_response[:meta][:message].downcase).to include "email"
      end
    end
  end
end