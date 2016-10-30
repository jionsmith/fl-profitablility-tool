module V1
  class ExpenseSerializer < ActiveModel::Serializer
    attributes :id, :name, :job, :price, :order_value, :added_date

    def price
      sprintf "$%.1f", object.price.round(1)
    end

    def added_date
      object.added_date.strftime("%d %b %Y")
    end

    # def resource_rate
    #   sprintf "$%.1f", object.resource_rate.round(1)
    # end

  end
end
