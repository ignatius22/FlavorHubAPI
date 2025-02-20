class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :username, :role, :email, :authenticated
  has_one :profile
end
