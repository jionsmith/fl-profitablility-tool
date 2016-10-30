class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.string :name
      t.string :job
      t.decimal :price
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
