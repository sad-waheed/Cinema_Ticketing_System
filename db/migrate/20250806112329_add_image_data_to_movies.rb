class AddImageDataToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :image_data, :binary, limit: 10.megabytes
  end
end
