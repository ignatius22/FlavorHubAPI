class User < ApplicationRecord
    before_validation :set_default_role, on: :create


    validates :email, uniqueness: true
    validates :username, uniqueness: true
    validates_format_of :email, with: /@/
    validates :password_digest, presence: true
    validates :role, presence: true

    has_secure_password


    private
    def set_default_role
        self.role ||= "user"
    end
end
