module V1
	class ProjectTimelinesController < ApplicationApiController
		before_action :set_project_timeline, only: [:show, :edit, :update, :destroy]
		before_action :set_project

		def new
		end

		def index
			@project_timelines = @project.project_timelines.default
			render json: @project_timelines, each_serializer: ProjectTimelineSerializer
		end

		def create
			@project_timeline = ProjectTimeline.new(:project_id => @project.id)
			if @project_timeline.save
				render json: @project_timeline, serializer: ProjectTimelineSerializer
			else
				render json: { error: 'create_project_timeline_error', error_messages: 'There is a error while saving a project_timeline' }, status: 401
			end
		end

		def update
			# @project_timeline 
			if @project_timeline.update_attributes(project_timeline_params)
				render json: @project_timeline, serializer: ProjectTimelineSerializer
			else
				render json: { error: 'update_project_timeline_error', error_messages: 'There is a error while saving a project_timeline' }, status: 401
			end
		end

		def show
			render json: @project_timeline, serializer: ProjectTimelineSerializer
		end

		private

			def set_project
				@project = Project.find(params[:project_id])
			end

			def set_project_timeline
				@project_timeline = ProjectTimeline.find(params[:id])
			end

			def project_timeline_params
				params.require(:project_timeline).permit()
			end
			
	end
end