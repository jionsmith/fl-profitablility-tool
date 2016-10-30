module V1
	class ResourceTimelinesController < ApplicationApiController
		before_action :set_resource_timeline, only: [:show, :edit, :update, :destroy]
		# before_action :set_project

		def new
		end

		def index
			render json: @project, serializer: ResourceTimelineSerializer
		end

		def create
			# @resource_timeline = ResourceTimeline.new(resource_timeline_params)
			# @resource_timeline.project = @project
			# if @resource_timeline.save
			# 	render json: @resource_timeline, serializer: ResourceTimelineSerializer
			# else
			# 	render json: { error: 'create_resource_timeline_error', error_messages: 'There is a error while saving a resource_timeline' }, status: 401
			# end
		end

		def update
			# @resource_timeline 
			if @resource_timeline.update_attributes(resource_timeline_params)
				# render json: @project, serializer: ResourceTimelineSerializer
				render json: @resource_timeline, serializer: ResourceTimelineSerializer	
			else
				render json: { error: 'update_resource_timeline_error', error_messages: 'There is a error while saving a resource_timeline' }, status: 401
			end
		end

		def show
			render json: @resource_timeline, serializer: ResourceTimelineSerializer
		end

		private

			def set_project
				@project = Project.find(params[:project_id])
			end

			def set_resource_timeline
				@resource_timeline = ResourceTimeline.find(params[:id])
			end

			def resource_timeline_params
				params.require(:resource_timeline).permit(:hours)
			end
			
	end
end