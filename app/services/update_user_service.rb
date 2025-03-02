# app/services/update_user_service.rb
class UpdateUserService
  Result = Struct.new(:success?, :user, :errors, keyword_init: true)

  def self.call(current_user, target_user, params)
    new(current_user, target_user, params).call
  end

  def initialize(current_user, target_user, params)
    @current_user = current_user
    @target_user = target_user
    @params = params
  end

  def call
    @target_user.instance_variable_set(:@current_user, @current_user) # Pass current_user to the model
    if @target_user.update(@params)
      Result.new(success?: true, user: @target_user, errors: [])
    else
      Result.new(success?: false, user: @target_user, errors: @target_user.errors.full_messages)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, user: @target_user, errors: [e.message])
  rescue StandardError => e
    Result.new(success?: false, user: @target_user, errors: ["An unexpected error occurred"])
  end
end