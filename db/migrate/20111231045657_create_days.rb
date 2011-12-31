class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.date :dt

      t.timestamps
    end

    add_column :activities, :day_id, :integer
  end
end
