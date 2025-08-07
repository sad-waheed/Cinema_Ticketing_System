# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_06_112329) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "booking_seats", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "seat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "show_id", null: false
    t.index ["booking_id"], name: "index_booking_seats_on_booking_id"
    t.index ["seat_id"], name: "index_booking_seats_on_seat_id"
    t.index ["show_id"], name: "index_booking_seats_on_show_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "show_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_bookings_on_created_at"
    t.index ["show_id"], name: "index_bookings_on_show_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "halls", force: :cascade do |t|
    t.string "name", null: false
    t.integer "seats_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movies", force: :cascade do |t|
    t.string "title", null: false
    t.string "rating", null: false
    t.integer "duration", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.binary "image_data"
  end

  create_table "seats", force: :cascade do |t|
    t.bigint "hall_id", null: false
    t.string "row", null: false
    t.integer "seat_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hall_id", "row", "seat_number"], name: "index_seats_on_hall_id_and_row_and_seat_number", unique: true
    t.index ["hall_id"], name: "index_seats_on_hall_id"
  end

  create_table "shows", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "hall_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hall_id", "start_time"], name: "index_shows_on_hall_id_and_start_time"
    t.index ["hall_id"], name: "index_shows_on_hall_id"
    t.index ["movie_id"], name: "index_shows_on_movie_id"
    t.index ["start_time"], name: "index_shows_on_start_time"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "booking_seats", "bookings"
  add_foreign_key "booking_seats", "seats"
  add_foreign_key "booking_seats", "shows"
  add_foreign_key "bookings", "shows"
  add_foreign_key "bookings", "users"
  add_foreign_key "seats", "halls"
  add_foreign_key "shows", "halls"
  add_foreign_key "shows", "movies"
end
