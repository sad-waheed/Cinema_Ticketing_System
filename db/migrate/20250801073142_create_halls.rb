class CreateHalls < ActiveRecord::Migration[8.0]
  def change
    create_table :halls do |t|
      t.string :name, null: false
      t.integer :seats_count, default: 0, null: false

      t.timestamps
    end
  end
end
