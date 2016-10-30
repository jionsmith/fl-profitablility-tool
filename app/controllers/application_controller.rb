class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :init_action

  def init_action
  	CUSTOM_CONFIG[:root_url] = root_url
  end
end
