module ServicePattern
    extend ActiveSupport::Concern
  
    Success = Struct.new(:product)
    Failure = Struct.new(:errors)
end