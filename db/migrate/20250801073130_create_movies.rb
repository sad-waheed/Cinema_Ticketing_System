class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.string :rating, null: false
      t.integer :duration, null: false

      t.timestamps
    end
  end
end
