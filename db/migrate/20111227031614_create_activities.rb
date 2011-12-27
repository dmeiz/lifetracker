class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :category_id
      t.datetime :start_at
      t.datetime :end_at
      t.string :memo

      t.timestamps
    end
  end
end
