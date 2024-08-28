class UpdateProductService
    Result = Struct.new(:success?, :user, :errors)
  
    def initialize(user, user_params)
      @user = user
      @user_params = user_params
    end
  
    def call
      if @user.update(@user_params)
        Result.new(true, @user, [])
      else
        Result.new(false, @user, @user.errors.full_messages)
      end
    end
  
    private
  
    attr_reader :user, :user_params
end
  