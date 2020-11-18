require 'jwt'

module UserAuth
  class AuthToken
    attr_reader :token
    attr_reader :payload
    attr_reader :lifetime

    def initialize(lifetime: nil, payload: {}, token: nil, options: {})
      if token.present?
        @payload, _ = JWT.decode(token.to_s, decode_key, true, decode_options.merge(options))
        @token = token
      else
        @lifetime = lifetime || UserAuth.token_lifetime
        @payload = claims.merge(payload)
        @token = JWT.encode(@payload, secret_key, algorithm, header_fields)
      end
    end

    # token_lifetimeの日本語変換を返す
    def lifetime_text
      time, period = @lifetime.inspect.sub(/s\z/,"").split
      time + I18n.t("datetime.periods.#{period}", default: "")
    end

    private

      # エンコードキー(config/initiazers/user_auth.rb)
      def secret_key
        UserAuth.token_secret_signature_key.call
      end

      # デコードキー(config/initiazers/user_auth.rb)
      def decode_key
        UserAuth.token_public_key || secret_key
      end

      # アルゴリズム(config/initiazers/user_auth.rb)
      def algorithm
        UserAuth.token_signature_algorithm
      end

      # オーディエンスの値がある場合のみtrueを返す
      def verify_audience?
        UserAuth.token_audience.present?
      end

      # オーディエンス(config/initiazers/user_auth.rb)
      def token_audience
        verify_audience? && UserAuth.token_audience.call
      end

      # トークンの有効期限を秒で返す
      def token_lifetime
        @lifetime.from_now.to_i
      end

      # デコード時のオプション
      def decode_options
        {
          aud:        token_audience,
          verify_aud: verify_audience?,
          algorithm:  algorithm
        }
      end

      # デフォルトクレーム
      def claims
        _claims = {}
        _claims[:exp] = token_lifetime
        _claims[:aud] = token_audience if verify_audience?
        _claims
      end

      # エンコード時のヘッダー
      def header_fields
        { typ: "JWT" }
      end

      # subjectからユーザーを検索する
      def entity_for_user
        User.find @payload["sub"]
      end
    # privateメソッド ここまで
  end
end
