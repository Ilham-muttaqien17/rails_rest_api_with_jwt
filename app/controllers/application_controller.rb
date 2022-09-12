class ApplicationController < ActionController::API
  def encode_token(payload)
    JWT.encode(payload, 'secret_key')
  end

  def decode_token
    auth_header = request.headers['Authorization']
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, 'secret_key', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def authorized_user
    decoded_token = decode_token()
    if decode_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by_id(user_id)
    end
  end

  def authorize
    authorized_user
    if !authorized_user.present?
      render json: { status: "failed", message: "You have to login first!" }, status: :unauthorized
    end
  end
end
