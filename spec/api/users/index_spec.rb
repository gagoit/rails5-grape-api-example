# encoding: utf-8
require "rails_helper"

describe "User APIs"  do
  
  before(:each) {
    @user = create :user
    @u_token = @user.user_tokens.create
  }

  describe "GET #index" do

    context "when success" do
      before(:each) do
        api_authorization_header(@u_token.token)
      end

      after do
        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:success]
      end

      it "render array with a user" do
        get "/api/users", params: {}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data[:users].length).to eql 1

        json_event = json_data[:users][0]

        expect(json_event[:uid]).to eql @user.id
        expect(json_event[:email]).to eql @user.email
        expect(json_event[:name]).to eql @user.name

        expect(json_response[:meta][:current_page]).to eql 1
        expect(json_response[:meta][:next_page]).to eql -1
        expect(json_response[:meta][:prev_page]).to eql -1
        expect(json_response[:meta][:total_pages]).to eql 1
        expect(json_response[:meta][:total_count]).to eql 1
      end

      it "render the users json in page = 1 & per_page = 20" do
        sleep 2
        @user1 = create :user

        get "/api/users", params: {page: 1, per_page: 20}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data[:users].length).to eql 2

        json_user = json_data[:users][0]

        expect(json_user[:uid]).to eql @user1.id
        expect(json_user[:email]).to eql @user1.email
        expect(json_user[:name]).to eql @user1.name

        json_user = json_data[:users][1]

        expect(json_user[:uid]).to eql @user.id
        expect(json_user[:email]).to eql @user.email
        expect(json_user[:name]).to eql @user.name

        expect(json_response[:meta][:current_page]).to eql 1
        expect(json_response[:meta][:next_page]).to eql -1
        expect(json_response[:meta][:prev_page]).to eql -1
        expect(json_response[:meta][:total_pages]).to eql 1
        expect(json_response[:meta][:total_count]).to eql 2
      end

      it "render the events json in page = 1 & per_page = 1" do
        sleep 2
        @user1 = create :user

        get "/api/users", params: {page: 1, per_page: 1}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data[:users].length).to eql 1

        json_user = json_data[:users][0]

        expect(json_user[:uid]).to eql @user1.id
        expect(json_user[:email]).to eql @user1.email
        expect(json_user[:name]).to eql @user1.name

        expect(json_response[:meta][:current_page]).to eql 1
        expect(json_response[:meta][:next_page]).to eql 2
        expect(json_response[:meta][:prev_page]).to eql -1
        expect(json_response[:meta][:total_pages]).to eql 2
        expect(json_response[:meta][:total_count]).to eql 2
      end

      it "render the events json in page = 2 & per_page = 1" do
        sleep 2
        @user1 = create :user

        get "/api/users", params: {page: 2, per_page: 1}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data[:users].length).to eql 1

        json_user = json_data[:users][0]

        expect(json_user[:uid]).to eql @user.id
        expect(json_user[:email]).to eql @user.email
        expect(json_user[:name]).to eql @user.name

        expect(json_response[:meta][:current_page]).to eql 2
        expect(json_response[:meta][:next_page]).to eql -1
        expect(json_response[:meta][:prev_page]).to eql 1
        expect(json_response[:meta][:total_pages]).to eql 2
        expect(json_response[:meta][:total_count]).to eql 2
      end
    end

    context "when has error" do
      it "render the error code with message when un-authentication" do
        get "/api/users", params: {}, headers: request_headers

        json_data = json_response[:data]

        expect(json_data.blank?).to eql true

        expect(json_response[:meta][:code]).to eql RESPONSE_CODE[:unauthorized]
        expect(json_response[:meta][:message]).to include I18n.t('errors.not_authenticated')
        # expect(json_response[:meta][:message].downcase).to include "email"
      end
    end
  end
end