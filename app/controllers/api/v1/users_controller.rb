module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize, only: [:show, :index, :update, :destroy]
      def index
        @users= User.all
        render json: {status: "success", data: @users}
      end

      def create
        @user = User.new(users_params)
        if @user.save
          render json: {status: "success", data: @user}, status: :created
        else
          render json: {status: "failed", message: "Failed to add new user"}, status: :bad_request
        end
      end

      def show 
        @user = User.find_by_id(params[:id])
        if !@user.nil?
          render json: {status: "success", data: @user}
        else
          render json: {status: "failed", message: "User with id #{params[:id]} is not found!"}, status: :not_found
        end
      end

      def update 
        @user = User.find_by_id(params[:id])

        if @user.nil?
          return render json: { status: "failed", message: "User with id #{params[:id]} is not found!" }, status: :not_found
        end

        if @user.update(users_params)
          render json: { status: "success", message: "User has been updated!" }
        else
          render json: { status: "failed", message: "Failed to update user with id #{params[:id]}" }, status: :bad_request
        end
      end

      def destroy
        @user = User.find_by_id(params[:id])
        if @user.present?
          @user.destroy
          return render json: { status: "success", message: "User has been deleted!" }
        else
          return render json: { status: "failed", message: "Failed, user with id #{params[:id]} is not found!"}, status: :not_found
        end
      end

      def register
        @user = User.new(users_params)
        @user.password = params[:password_digest]

        if @user.save
          token = encode_token({ user_id: @user.id })
          render json: { users: @user, token: token }, status: :created
        else
          render json: { status: "failed", message: 'Register user is failed!'}, status: :bad_request
        end
      end

      def login 
        @user = User.find_by_email(params[:email])

        if @user.nil?
          return render json: { status: "failed", message: "Cannot find user with email address #{users_params[:email]}!"}, status: :not_found
        end

        binding.pry

        if @user.password == params[:password]
          token = encode_token({ user_id: @user.id })
          render json: { status: "success", message: "Login success!", token: token}, status: :ok
        else
          render json: { status: "failed", message: "Login failed, password doesn't match with email!"}, status: :unauthorized
        end
      end

      private

      def users_params
        params.require(:user).permit(:name, :email, :password_digest)
      end
    end
  end
end
