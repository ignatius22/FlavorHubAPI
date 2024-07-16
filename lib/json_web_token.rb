class JsonWebToken
    SECRET_KEY = Rails.application.credentials.secret_key_base.to_s
  
    def self.encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end
  
    def self.decode(token)
      begin
        decoded = JWT.decode(token, SECRET_KEY).first
        HashWithIndifferentAccess.new(decoded)
      rescue JWT::DecodeError => e
        Rails.logger.warn("JWT Decode Error: #{e.message}")
        nil
      rescue JWT::ExpiredSignature => e
        Rails.logger.warn("JWT Expired Signature: #{e.message}")
        nil
      rescue JWT::VerificationError => e
        Rails.logger.warn("JWT Verification Error: #{e.message}")
        nil
      end
    end
  end