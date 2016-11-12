require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Ihealth < OmniAuth::Strategies::OAuth2
      AVAILABLE_API_NAMES = 'OpenApiActivity OpenApiBG OpenApiBP OpenApiSleep OpenApiSpO2 OpenApiUserInfo OpenApiWeight'
      DEFAULT_API_NAMES   = 'OpenApiUserInfo'

      extra do
       {
         user_info: user_data,
         raw_info:  raw_info }
      end

      info { user_data.slice(:name, :nickname, :image) }


      option :client_options, {
        authorize_url:  '/OpenApiV2/OAuthv2/userauthorization/',
        site:           'https://api.ihealthlabs.com:8443',
        token_method:   :get,
        token_url:      '/OpenApiV2/OAuthv2/userauthorization/' }

      option :is_new,                 'true'
      option :name,                   'ihealth'
      option :provider_ignores_state, true
      option :response_type,          'code'
      option :scope,                  DEFAULT_API_NAMES

      uid { access_token[:user_id] }


      def authorize_params
        super.tap do |params|
          params[:APIName]       = options.scope
          params[:IsNew]         = options.is_new
          params[:response_type] = options.response_type
        end
      end

      def build_access_token
        hashified_params = token_params.to_hash symbolize_keys: true
        token_url_params = { code: request.params['code'], redirect_uri: callback_url }.merge(hashified_params)

        parsed_response = client.request(
          options.client_options.token_method,
          client.token_url(token_url_params),
          parse: :json).parsed

        hash = {
          access_token:  parsed_response['AccessToken'],
          api_name:      parsed_response['APIName'],
          client_para:   parsed_response['client_para'],
          expires_in:    parsed_response['Expires'],
          refresh_token: parsed_response['RefreshToken'],
          user_id:       parsed_response['UserID'] }

        ::OAuth2::AccessToken.from_hash(client, hash)
      end

      def raw_info
        @raw_info ||= begin
          access_token.options[:mode] = :query

          user_profile_params = {
            client_id:      client.id,
            client_secret:  client.secret,
            access_token:   access_token.token }

          user_profile_params.merge!({ sc: options.sc, sv: options.sv }) if options.sc && options.sv

          url = "/openapiv2/user/#{access_token[:user_id]}.json/?#{user_profile_params.to_param}"

          access_token.get(url, parse: :json).parsed
        end
      end

      def token_params
        super.tap do |params|
          params[:client_id]     = client.id
          params[:client_secret] = client.secret
          params[:grant_type]    = 'authorization_code'
        end
      end

      def user_data
        @user_data ||= begin
          {
            birthday: Time.at(raw_info['dateofbirth']).to_date.strftime('%Y-%m-%d'),
            gender:   raw_info['gender'].downcase,
            height:   calc_height(info['height'], info['HeightUnit']),
            image:    URI.unescape(raw_info['logo']),
            name:     raw_info['nickname'],
            nickname: raw_info['nickname'],
            weight:   calc_weight(info['weight'], info['WeightUnit']) }
        end
      end

      private

        CM_TO_IN_CONVERSION     = 0.393701
        FT_TO_IN_CONVERSION     = 12
        KG_TO_LBS_CONVERSION    = 2.20462
        STONE_TO_LBS_CONVERSION = 14

        def calc_height(value, unit)
          case(unit)
          when 0  # value is in cm
            return value * CM_TO_IN_CONVERSION
          when 1  # value is in feet
            return value * FT_TO_IN_CONVERSION
          else    # unrecognized unit
            return value
         end
       end

        def calc_weight(value, unit)
          case(unit)
          when 0  # value is in kg
            return value * KG_TO_LBS_CONVERSION
          when 1  # value is in lbs
            return value
          when 2  # value is in stone
            return value * STONE_TO_LBS_CONVERSION
          else    # unrecognized unit
            return value
          end
        end
    end
  end
end

OmniAuth.config.add_camelization 'ihealth', 'Ihealth'
