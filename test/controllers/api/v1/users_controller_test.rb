require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest

  rescue_from UserAuth.not_found_exception_class, with: :not_found

  private

  # メールアドレスからアクティブなユーザーを返す
  def entity
    @_entity ||= User.find_activated(auth_params[:email])
  end

  # トークンを発行する
  def auth
    @_auth ||= UserAuth::AuthToken.new(payload: { sub: entity.id })
  end

  # クッキーに保存するトークン
  def cookie_token 
    {
      value: auth.token,
      expires: Time.at(auth.payload[:exp]),
      secure: Rails.env.production?,
      http_only: true
    }
  end

  # entityが存在しない、entityのパスワードが一致しない場合に404エラーを返す
  def authenticate
    unless entity.present? && entity.authenticate(auth_params[:password])
      raise UserAuth.not_found_exception_class
    end
  end

  # NotFoundエラーが発生時にヘッダーレスポンスのみを返す
  def not_found
    head(:not_found)
  end

  def auth_params
    params.require(:auth).permit(:email, :password)
  end
end
