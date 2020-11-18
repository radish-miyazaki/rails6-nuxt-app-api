ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# gem 'minitest-reporters' setup
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase

  # プロセスが分岐した直後に呼び出し
  parallelize_setup do |worker|
    load "#{Rails.root}/db/seeds.rb"
  end

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # テスト用の共通ユーザー
  def active_user
    User.find_by(activated: true)
  end

  def api_url(path = "/")
    "#{ENV["BASE_URL"]}/api/v1#{path}"
  end

  # コントローラのJSONレスポンスを受け取る
  def response_body
    JSON.parse(@response.body)
  end

  # テスト用のCookieにトークンを保存する
  def logged_in(user)
    cookies[UserAuth.token_access_key] = user.to_token
  end

end
