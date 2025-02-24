# app/services/toggle_favorite_service.rb
class ToggleFavoriteService
  Result = Struct.new(:message, keyword_init: true)

  # Class-level method to instantiate and call the service
  def self.call(user:, product:)
    new(user, product).call
  end

  def initialize(user, product)
    @user = user
    @product = product
  end

  def call
    raise ArgumentError, "User cannot be nil" unless @user
    favorite = @user.favorites.find_by(product: @product)
    if favorite
      favorite.destroy!
      Result.new(message: "Product unfavorited successfully")
    else
      @user.favorites.create!(product: @product)
      Result.new(message: "Product favorited successfully")
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to toggle favorite: #{e.message}"
    raise
  rescue ArgumentError => e
    Rails.logger.error "Invalid user in ToggleFavoriteService: #{e.message}"
    raise
  end

  private

  attr_reader :user, :product
end