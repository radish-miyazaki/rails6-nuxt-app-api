module UserAuth
  # JWT有効期限のデフォルト値
  mattr_accessor :token_lifetime
  self.token_lifetime = 2.week

  # 受信者を識別する文字列を指定する
  mattr_accessor :token_audience
  self.token_audience = -> {
    ENV["API_DOMAIN"]
  }

  # 署名アルゴリズムを指定する
  mattr_accessor :token_signature_algorithm
  self.token_signature_algorithm = "HS256"

  # 署名に使用する秘密鍵
  mattr_accessor :token_secret_signature_key
  self.token_secret_signature_key = -> {
    Rails.application.credentials.secret_key_base
  }

  # 署名に使用する公開鍵（今回は使用しないのでnil）
  mattr_accessor :token_public_key
  self.token_public_key = nil

  # Cookeiに保存するオブジェクトキーを指定
  mattr_accessor :token_access_key
  self.token_access_key = :access_token

  # ログインユーザーが見つからない場合のRailsの例外を指定
  mattr_accessor :not_found_expection_class
  self.not_found_expection_class = ActiveRecord::RecordNotFound
end