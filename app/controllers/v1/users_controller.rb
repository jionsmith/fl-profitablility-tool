module V1
  class UsersController < ApplicationApiController

    skip_before_action :authenticate_user_from_token!, only: [:create, :update_organisation, :signin, :member_signup, :get_member_by_token, :send_forgot_email, :forgot_pass]

    def create
      @user = User.new user_params
      if @user.save
        render json: @user, serializer: V1::SessionSerializer, root: nil
      else
        render json: { error: 'user_create_error', error_messages: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def project_tags
      parent_user = current_user.created_by_id == 0 ? current_user : current_user.parent
      render json: parent_user.project_tags, each_serializer: V1::ProjectTagSerializer
    end

    def update_organisation
      @user = User.find(params[:user][:id])
      project_tags = params[:user][:project_tags]
      organisation_name = params[:user][:organisation_name]

      return render json: { error: 'user_update_organisation_error', error_messages: ['Organisation name is required'] }, status: :unprocessable_entity if organisation_name.blank?

      if project_tags.blank? || project_tags.count == 0
        return render json: { error: 'user_update_organisation_error', error_messages: ['Project type is required at least one'] }, status: :unprocessable_entity
      end
      @user.organisation_name = organisation_name
      @user.step = 1
      @user.project_tags.delete_all
      project_tags.each do |project_tag|
        obj_project_tag = ProjectTag.new(:user_id => @user.id, :name => project_tag)
        obj_project_tag.save
      end

      if @user.save
        render json: @user, serializer: V1::SessionSerializer, root: nil
      else
        render json: { error: 'user_update_organisation_error', error_messages: @user.errors.full_messages }, status: :unprocessable_entity
      end

    end

    def signin
      @user = User.find_for_database_authentication(email: params[:email])
      return invalid_login_attempt unless @user

      if @user.valid_password?(params[:password])
        sign_in :user, @user
        render json: @user, serializer: SessionSerializer, root: nil
      else
        invalid_login_attempt
      end
    end

    def team_member
      render json: current_user, serializer: TeamMemberSerializer, root: nil
    end

    def make_admin
      if !current_user.super && !current_user.admin
        return render json: { error: 'make_admin_error', error_messages: ['Unpermitted user']}, status: 401
      end
      user = User.find(params[:member_id])
      if user.present? && !user.super && !user.admin
        user.admin = true
        if user.save
          render json: { message: 'success'}, status: 200
        else
          render json: { error: 'make_admin_error', error_messages: ['Processing error']}, status: 401
        end
      end
    end

    def remove_member
      if !current_user.super && !current_user.admin
        return render json: { error: 'remove_member_error', error_messages: ['Unpermitted user']}, status: 401
      end
      user = User.find(params[:member_id])
      if user.present? && !user.super && !user.admin
        if user.delete
          render json: { message: 'success'}, status: 200
        else
          render json: { error: 'remove_member_error', error_messages: ['Processing error']}, status: 401
        end
      end
    end

    def update_profile
      if params[:user][:old_password].blank?
        current_user.email = params[:user][:email]
        current_user.name = params[:user][:name]
        if current_user.save
          return render json: current_user, serializer: SessionSerializer, root: nil
        else
          return render json: { error: 'update_profile_error', error_messages: current_user.errors.full_messages}, status: 401
        end
      end

      if current_user.valid_password?(params[:user][:old_password])
        if current_user.update_attributes(user_params)
          return render json: current_user, serializer: SessionSerializer, root: nil
        else
          return render json: { error: 'update_profile_error', error_messages: current_user.errors.full_messages}, status: 401
        end
      else
        return render json: { error: 'update_profile_error', error_messages: ['Invalid current password']}, status: 401
      end
    end

    def complete_member
      current_user.password = params[:user][:password]
      current_user.password_confirmation = params[:user][:password_confirmation]
      current_user.name = params[:user][:name]
      current_user.invite_token = nil
      if current_user.save
        return render json: current_user, serializer: SessionSerializer, root: nil
      else
        return render json: { error: 'update_profile_error', error_messages: current_user.errors.full_messages}, status: 401
      end
    end

    def member_invite
      if current_user.super
        invite_email = params[:invite_email]
        user = User.new(:email => invite_email, :password => SecureRandom.hex(5), :super => false, :admin => false, :step => 1)
        user.created_by_id = current_user.id
        user.invite_token = SecureRandom.hex(8)
        if user.save
          UserMailer.member_invite(user).deliver
          return render json: { message: 'success'}, status: 200
        end
      end
      return render json: { message: 'failed to invite'}, status: 401
    end

    def send_forgot_email
      forgot_email = params[:forgot_email]
      user = User.find_by_email(forgot_email)
      if user.present?
        user.invite_token = SecureRandom.hex(8)
        if user.save
          UserMailer.forgot_email(user).deliver
          return render json: { message: 'success'}, status: 200
        end

      end
      return render json: { message: 'failed to send forgot email'}, status: 401
    end

    def member_signup
      token = params[:token]
      if token.blank?
        return redirect_to root_path
      end
      member = User.find_by_invite_token(token)
      if member.blank?
        return redirect_to root_path
      end
      redirect_to "/client/app/#/member-signup/#{token}"
    end

    def forgot_pass
      token = params[:token]
      if token.blank?
        return redirect_to root_path
      end
      member = User.find_by_invite_token(token)
      if member.blank?
        return redirect_to root_path
      end
      redirect_to "/client/app/#/forgot-pass/#{token}"
    end

    def get_member_by_token
      @user = User.find_by_invite_token(params[:token])
      if params[:token].blank?
        return invalid_login_attempt
      end
      return invalid_login_attempt unless @user

      render json: @user, serializer: SessionSerializer, root: nil
    end

    private

    def user_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation, :super, :admin)
    end

    def invalid_login_attempt
      warden.custom_failure!
      render json: {error: 'sessions_controller.invalid_login_attempt', error_messages: ['Email or password is invalid.']}, status: :unprocessable_entity
    end
  end
end
