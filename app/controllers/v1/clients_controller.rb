module V1
	class ClientsController < ApplicationApiController
		before_action :set_client, only: [:show, :edit, :update, :destroy]

		def new
		end

		def index
			@clients = current_user.parent.all_clients
			render json: @clients, each_serializer: ClientEachSerializer
		end

		def create
			@client = Client.new(client_params)
			@client.created_by_id = current_user.id
			@client.primary_user_id = current_user.created_by_id == 0 ? current_user.id : current_user.created_by_id
			if @client.save
				render json: @client, serializer: ClientSerializer
			else
				render json: { error: 'create_client_error', error_messages: ['There is a error while saving a client'] }, status: 401
			end
		end

		def update
			# @client
			if @client.update_attributes(client_params)
				render json: @client, serializer: ClientSerializer
			else
				render json: { error: 'update_client_error', error_messages: ['There is a error while saving a client'] }, status: 401
			end
		end

		def destroy
			@client.destroy
			render json: { success: 'success'}, status: 200
		end

		def show
			render json: @client, serializer: ClientSerializer
		end

		def all
			@clients = current_user.all_clients
			render json: @clients, each_serializer: ClientEachSerializer
		end

		private
			def client_params
				params.require(:client).permit(:name, :industry, :location, :size)
			end

			def set_client
				@client = Client.find(params[:id])
			end
	end
end
