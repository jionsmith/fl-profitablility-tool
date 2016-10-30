class HomeController < ApplicationController
	def index
		redirect_to '/client/app/'
	end
end