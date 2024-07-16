module ResponseHandler
    def handle_response(result, success_status, resource_name = nil)
      if result[:success]
        render json: result.except(:success), status: success_status
      else
        render json: { message: "Operation failed", errors: result[:errors] }, status: :unprocessable_entity
      end
    end
end