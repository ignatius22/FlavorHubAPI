# app/lib/concerns/pagination.rb
module Pagination
    extend ActiveSupport::Concern
    
    def paginate(collection)
      collection.page(params[:page]).per(params[:per_page] || 20)
    end
end