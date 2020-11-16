require "validator/email_validator"

class User < ApplicationRecord

  # バリデーション直前の処理##################################
  before_validation :downcase_email  
  # /バリデーション直前の処理#################################

  # gem bcrypt
  has_secure_password

  # validates(入力規則)
  validates :name,  presence: true,
                    length: { maximum: 30, allow_blank: true }

  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password,  presence: true,
                        length: { minimum: 8 },
                        format: {
                          with:     VALID_PASSWORD_REGEX,
                          message:  :invalid_password
                        },
                        allow_blank: true

  validates :email, presence: true,
                    email: { allow_blank: true}

  ## methods

  # class method #####################################
  class << self
    # emailからアクティブなユーザーを返す
    def find_activated(email)
      find_by(email: email, activated: true)
    end
  end
  # /class method ####################################

  # 自分以外の同じemailのアクティブなユーザーがいる場合にはtrueを返す
  def email_activated?
    users = User.where.not(id: id)
    users.find_activated(email).present?
  end


  # private instance method ##########################
  private

    def downcase_email
      self.email.downcase! if email
    end

  # /private instance method ########################

end
