# app/services/application_service.rb
class ApplicationService
    def self.call(*args, &block)
      new(*args, &block).call
    end
    def success!(result)
      OpenStruct.new(success?: true, **result)
    end
  
    def failure!(errors)
      OpenStruct.new(success?: false, errors: errors)
    end
end