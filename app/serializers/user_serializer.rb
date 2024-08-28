class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :username, :role
  has_one :profile
end
