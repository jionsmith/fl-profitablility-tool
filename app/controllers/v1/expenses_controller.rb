module V1
	class ExpensesController < ApplicationApiController
		before_action :set_expense, only: [:show, :edit, :update, :destroy]
		before_action :set_project, except: [:update_order]

		def new
		end

		def index
			@expenses = @project.expenses.default
			render json: @expenses, each_serializer: ExpenseSerializer
		end

		def create
			@expense = Expense.new(expense_params)
			@expense.project = @project
			if @expense.save
				render json: @project, serializer: ProjectSerializer
			else
				render json: { error: 'create_expense_error', error_messages: 'There is a error while saving a expense' }, status: 401
			end
		end

		def update
			# @expense 
			# @expense.role = params[:expense][:role] if params[:expense][:role].present?
			# @expense.name = params[:expense][:name] if params[:expense][:name].present?
			# @expense.client_rate = params[:expense][:client_rate].gsub(/[^0-9.]/, '') if params[:expense][:client_rate].present?
			# @expense.expense_rate = params[:expense][:expense_rate].gsub(/[^0-9.]/, '') if params[:expense][:expense_rate].present?

			if params[:expense][:field_name] == 'name'
				@expense.name = params[:expense][:value]
			elsif params[:expense][:field_name] == 'job'
				@expense.job = params[:expense][:value]
			elsif params[:expense][:field_name] == 'price'
				@expense.price = params[:expense][:value].gsub(/[^0-9.]/, '')
			elsif params[:expense][:field_name] == 'added_date'
				@expense.added_date = params[:expense][:value]
			end
			if @expense.save
				# render json: @expense, serializer: ExpenseSerializer
				# render json: @project, serializer: ProjectSerializer
				if params[:expense][:field_name] == 'name' || params[:expense][:field_name] == 'job' || params[:expense][:field_name] == 'added_date'
					render json: {value: params[:expense][:value]}
				elsif params[:expense][:field_name] == 'price'
					render json: {value: sprintf("$%.1f", @expense.price.round(1))}
				end
			else
				render json: { error: 'update_expense_error', error_messages: 'There is a error while saving a expense' }, status: 401
			end
		end

		def update_order
			orders = params[:orders]
			orders.each do |order|
				expense = Expense.find_by_id(order[:id])
				if expense.present?
					expense.order_value = order[:value];
					expense.save
				end
			end
			render json: { success: 'success'}, status: 200
		end

		def show
			render json: @expense, serializer: ExpenseSerializer
		end

		def destroy
			@expense.destroy
			render json: @project, serializer: ProjectSerializer
		end

		private

			def set_project
				@project = Project.find(params[:project_id])
			end

			def set_expense
				@expense = Expense.find(params[:id])
			end

			def expense_params
				params.require(:expense).permit(:name, :job, :price, :order_value)
			end
			
	end
end