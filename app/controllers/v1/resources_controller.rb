module V1
	class ResourcesController < ApplicationApiController
		before_action :set_resource, only: [:show, :edit, :update, :destroy]
		before_action :set_project, except: [:update_order]

		def new
		end

		def index
			@resources = @project.resources.default
			render json: @resources, each_serializer: ResourceSerializer
		end

		def create
			@resource = Resource.new(resource_params)
			@resource.project = @project
			if @resource.save
				# render json: @resource, serializer: ResourceSerializer
				@project.create_resource_timelines_by_resource(@resource)
				render json: @project, serializer: ProjectSerializer
			else
				render json: { error: 'create_resource_error', error_messages: 'There is a error while saving a resource' }, status: 401
			end
		end

		def update
			# @resource 
			# @resource.role = params[:resource][:role] if params[:resource][:role].present?
			# @resource.name = params[:resource][:name] if params[:resource][:name].present?
			# @resource.client_rate = params[:resource][:client_rate].gsub(/[^0-9.]/, '') if params[:resource][:client_rate].present?
			# @resource.resource_rate = params[:resource][:resource_rate].gsub(/[^0-9.]/, '') if params[:resource][:resource_rate].present?

			if params[:resource][:field_name] == 'name'
				@resource.name = params[:resource][:value]
			elsif params[:resource][:field_name] == 'role'
				@resource.role = params[:resource][:value]
			elsif params[:resource][:field_name] == 'client_rate'
				@resource.client_rate = params[:resource][:value].gsub(/[^0-9.]/, '')
			elsif params[:resource][:field_name] == 'resource_rate'
				@resource.resource_rate = params[:resource][:value].gsub(/[^0-9.]/, '')				
			end
			if @resource.save
				# render json: @resource, serializer: ResourceSerializer
				# render json: @project, serializer: ProjectSerializer
				if params[:resource][:field_name] == 'name' || params[:resource][:field_name] == 'role'
					render json: {value: params[:resource][:value]}
				elsif params[:resource][:field_name] == 'client_rate'
					render json: {value: sprintf("$%.1f", @resource.client_rate.round(1))}
				elsif params[:resource][:field_name] == 'resource_rate'
					render json: {value: sprintf("$%.1f", @resource.resource_rate.round(1))}
				end
			else
				render json: { error: 'update_resource_error', error_messages: 'There is a error while saving a resource' }, status: 401
			end
		end

		def update_order
			orders = params[:orders]
			orders.each do |order|
				resource = Resource.find_by_id(order[:id])
				if resource.present?
					resource.order_value = order[:value];
					resource.save
				end
			end
			render json: { success: 'success'}, status: 200
		end

		def show
			render json: @resource, serializer: ResourceSerializer
		end

		def destroy
			@resource.destroy
			render json: @project, serializer: ProjectSerializer
		end

		private

			def set_project
				@project = Project.find(params[:project_id])
			end

			def set_resource
				@resource = Resource.find(params[:id])
			end

			def resource_params
				params.require(:resource).permit(:role, :name, :client_rate, :resource_rate, :is_estimated, :order_value)
			end
			
	end
end