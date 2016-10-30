module V1
	class ProjectsController < ApplicationApiController
		before_action :set_project, only: [:show, :edit, :update, :destroy]
		before_action :set_client, only: [:index, :create]

		def new
		end

		def index
			@projects = @client.projects
			render json: @projects, each_serializer: ProjectSerializer
		end

		def create
			@project = @client.projects.build(project_params)
			@project.created_by_id = current_user.id
			if @project.save
				# render json: @project, serializer: ProjectSerializer
				render json: @client, serializer: ClientSerializer
			else
				render json: { error: 'create_project_error', error_messages: 'There is a error while saving a project' }, status: 401
			end
		end

		def destroy
			@project.destroy
			render json: { success: 'success'}, status: 200
		end

		def update
			if @project.update_attributes(project_params)
				render json: @project, serializer: ProjectSerializer
			else
				render json: { error: 'update_project_error', error_messages: 'There is a error while saving a project' }, status: 401
			end
		end

		def show
			render json: @project, serializer: ProjectSerializer
		end

		private
			def project_params
				params.require(:project).permit(:name, :project_tag, :category, :gross_revenue)
			end

			def set_project
				@project = Project.find(params[:id])
			end

			def set_client
				@client = Client.find(params[:client_id])
			end
	end
end
