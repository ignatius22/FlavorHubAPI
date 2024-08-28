class ProfileSerializer
  include JSONAPI::Serializer

  attributes :id, :first_name, :last_name, :bio, :avatar, :phone_number, :address
end
