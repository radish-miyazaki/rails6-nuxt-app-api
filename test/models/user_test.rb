require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = active_user
  end

  test "name_validation" do
    
    # 入力必須
    user = User.new(name: "", email: "test@example.com", password: "password")
    user.save
    required_msg = ["名前を入力してください"]
    assert_equal(required_msg, user.errors.full_messages)
  
    # 文字数制限
    max = 30
    name = "a" * (max + 1)
    user.name = name
    user.save
    maxlength_msg = ["名前は30文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 30文字以内は正しく保存されているか
    name = "a" * 30
    user.name = name
    assert_difference("User.count", 1) do
      user.save
    end 
  end

  test "email_validation" do

    # 入力必須
    user = User.new(name: "test", email: "", password: "password")
    user.save
    required_msg = ["メールアドレスを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # 文字数制限
    max = 255
    domain = "@example.com"
    email = "a" * ((max + 1) - domain.length) + domain
    assert max < email.length

    user.email = email
    user.save
    maxlength_msg = ["メールアドレスは255文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 書式チェック
    ## 有効な値
    ok_emails = %w(
      A@EX.COM
      a-_@e-x.c-o_m.j_p
      a.a@ex.com
      a@e.co.js
      1.1@ex.com
      a.a+a@ex.com
    )
    ok_emails.each do |email|
      user.email = email
      assert user.save
    end

    ## 無効な値
    ng_emails = %w(
      aaa
      a.ex.com
      メール@ex.com
      a~a@ex.com
      a@|.com
      a@ex.
      .a@ex.com
      a＠ex.com
      Ａ@ex.com
      a@?,com
      １@ex.com
      "a"@ex.com
      a@ex@co.jp
    )

    ng_emails.each do |email|
      user.email = email
      user.save
      format_msg = ["メールアドレスは不正な値です"]
      assert_equal(format_msg, user.errors.full_messages)
    end
  end

  test "email_downcase" do
    email = "USER@EXAMPLE.COM"
    user = User.new(email: email)
    user.save
    assert user.email = email.downcase
  end

  test "activated_user_uniquiness" do
    email = "test@example.com"

    # アクティブユーザーがいない場合、同じメールアドレスが登録できるか
    count = 3
    assert_difference("User.count", count) do
      count.times do |n|
        User.create(name: "test", email: email, password: "password")
      end
    end

    # ユーザーがアクティブになった場合、バリデーションエラーを吐くか
    active_user = User.find_by(email: email)
    active_user.update!(activated: true)
    assert active_user.activated

    assert_no_difference("User.count") do
      user = User.new(name: "test", email: email, password: "password")
      user.save
      uniquiness_msg = ["メールアドレスはすでに存在します"]
      assert_equal(uniquiness_msg, user.errors.full_messages)
    end

    # アクティブユーザーがいなくなった場合、ユーザーは保存できているか
    active_user.destroy!
    assert_difference("User.count", 1) do
      User.create(name: "test", email: email, password: "password", activated: true)
    end

    # 一意性は保たれているか
    assert_equal(1, User.where(email: email, activated: true).count)
  end

  test "password_validation" do
    
    # 入力必須
    user = User.new(name: "test", email: "test@example.com", password: "")
    user.save
    required_msg = ["パスワードを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # min文字以上
    min = 8
    user.password = "a" * (min - 1)
    user.save
    minlength_msg = ["パスワードは8文字以上で入力してください"]
    assert_equal(minlength_msg, user.errors.full_messages)

    # max文字以下
    max = 72
    user.password = "a" * (max + 1)
    user.save
    maxlength_msg = ["パスワードは72文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 書式チェック
    ## 有効な値
    ok_passwords = %w(
      pass---word
      ________
      12341234
      ____pass
      pass----
      PASSWORD
    )
    ok_passwords.each do |password|
      user.password = password
      assert user.save
    end

    ## 無効な値
    ng_passwords = %w(
      pass/word
      pass.word
      |~=?+"a"
      １２３４５６７８
      ＡＢＣＤＥＦＧＨ
      password@
    )
    format_msg = ["パスワードは 半角英数字・ﾊｲﾌﾝ・ｱﾝﾀﾞｰﾊﾞｰ が使えます"]
    ng_passwords.each do |password|
      user.password = password
      user.save
      assert_equal(format_msg, user.errors.full_messages)
    end
  end
end
