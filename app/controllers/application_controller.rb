class ApplicationController < ActionController::API
  # クッキーを扱うモジュールを追加
  include ActionController::Cookies
  # JWTを検証し、正しければ発行主のユーザーを返すモジュールを追加
  include UserAuth::Authenticator

end
