module V1
	class TimelinesController < ApplicationApiController
		before_action :set_timeline, only: [:show, :edit, :update, :destroy]
		before_action :set_project

		def new
		end

		def index
			@timelines = @project.timelines.default
			render json: @timelines, each_serializer: TimelineSerializer
		end

		def create
			@timeline = Timeline.new(timeline_params)
			if @timeline.save
				@project.create_resource_timelines_by_timeline(@timeline)
				render json: @project, serializer: ProjectSerializer
				# render json: @timeline, serializer: TimelineSerializer
			else
				render json: { error: 'create_timeline_error', error_messages: 'There is a error while saving a timeline' }, status: 401
			end
		end

		def update
			# @timeline 
			if @timeline.update_attributes(timeline_params)
				render json: @timeline, serializer: TimelineSerializer
			else
				render json: { error: 'update_timeline_error', error_messages: 'There is a error while saving a timeline' }, status: 401
			end
		end

		def show
			render json: @timeline, serializer: TimelineSerializer
		end

		def destroy
			@timeline.destroy
			render json: @project, serializer: ProjectSerializer
		end

		private

			def set_project
				@project = Project.find(params[:project_id])
			end

			def set_timeline
				@timeline = Timeline.find(params[:id])
			end

			def timeline_params
				params.require(:timeline).permit(:project_id, :is_estimated)
			end
			
	end
end