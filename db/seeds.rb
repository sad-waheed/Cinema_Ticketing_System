# frozen_string_literal: true

# Clear existing data in dependency order
puts "Clearing existing data..."
BookingSeat.destroy_all
Booking.destroy_all
Show.destroy_all
Seat.destroy_all
Hall.destroy_all
Movie.destroy_all
User.destroy_all

puts "Creating users..."
# Create admin user
admin = User.create!(
  name: "Cinema Admin",
  email: "admin@cinema.com",
  password: "admin123",
  password_confirmation: "admin123",
  role: "admin"
)

# Create regular users
users = []
10.times do |i|
  users << User.create!(
    name: "User #{i + 1}",
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    role: "user"
  )
end

puts "Created #{User.count} users (1 admin, #{users.count} regular users)"

puts "Creating movies..."
movies = [
  {
    title: "The Great Adventure",
    duration: 120,
    rating: "PG-13"
  },
  {
    title: "Mystery of the Lost City",
    duration: 105,
    rating: "PG"
  },
  {
    title: "Comedy Night Out",
    duration: 95,
    rating: "PG-13"
  },
  {
    title: "Romantic Sunset",
    duration: 110,
    rating: "PG"
  },
  {
    title: "Action Hero Returns",
    duration: 135,
    rating: "R"
  },
  {
    title: "Sci-Fi Future",
    duration: 150,
    rating: "PG-13"
  }
]

created_movies = movies.map { |movie_attrs| Movie.create!(movie_attrs) }
puts "Created #{created_movies.count} movies"

puts "Creating halls..."
halls = []

# Hall 1 - Small hall
hall1 = Hall.create!(name: "Hall A", seats_count: 0) # Will be updated by counter_cache
halls << hall1

# Hall 2 - Medium hall
hall2 = Hall.create!(name: "Hall B", seats_count: 0)
halls << hall2

# Hall 3 - Large hall
hall3 = Hall.create!(name: "Hall C", seats_count: 0)
halls << hall3

puts "Created #{halls.count} halls"

puts "Creating seats..."
seat_configurations = [
  { hall: hall1, rows: ["A", "B", "C"], seats_per_row: 8 },    # 24 seats
  { hall: hall2, rows: ["A", "B", "C", "D"], seats_per_row: 10 }, # 40 seats
  { hall: hall3, rows: ["A", "B", "C", "D", "E", "F"], seats_per_row: 12 } # 72 seats
]

total_seats = 0
seat_configurations.each do |config|
  config[:rows].each do |row|
    (1..config[:seats_per_row]).each do |seat_num|
      Seat.create!(
        hall: config[:hall],
        row: row,
        seat_number: seat_num
      )
      total_seats += 1
    end
  end
end

puts "Created #{total_seats} seats across all halls"

puts "Creating shows..."
base_date = Date.current
shows = []

# Create shows for the next 7 days
(0..6).each do |day_offset|
  show_date = base_date + day_offset.days

  # Morning shows (10:00 AM)
  halls.each_with_index do |hall, hall_index|
    movie = created_movies[hall_index % created_movies.count]
    start_time = show_date.beginning_of_day + 10.hours
    end_time = start_time + movie.duration.minutes

    shows << Show.create!(
      movie: movie,
      hall: hall,
      start_time: start_time,
      end_time: end_time
    )
  end

  # Afternoon shows (2:30 PM)
  halls.each_with_index do |hall, hall_index|
    movie = created_movies[(hall_index + 2) % created_movies.count]
    start_time = show_date.beginning_of_day + 14.hours + 30.minutes
    end_time = start_time + movie.duration.minutes

    shows << Show.create!(
      movie: movie,
      hall: hall,
      start_time: start_time,
      end_time: end_time
    )
  end

  # Evening shows (7:00 PM)
  halls.each_with_index do |hall, hall_index|
    movie = created_movies[(hall_index + 4) % created_movies.count]
    start_time = show_date.beginning_of_day + 19.hours
    end_time = start_time + movie.duration.minutes

    shows << Show.create!(
      movie: movie,
      hall: hall,
      start_time: start_time,
      end_time: end_time
    )
  end
end

puts "Created #{shows.count} shows"

puts "Creating bookings..."
bookings = []
booking_seats_created = 0

# Create some bookings for shows (mix of confirmed, pending, and cancelled)
shows.sample(15).each_with_index do |show, index|
  # Randomly select 1-4 seats for this booking
  available_seats = show.hall.seats.to_a
  num_seats = rand(1..4)
  selected_seats = available_seats.sample(num_seats)

  # Create booking
  status = case index % 5
           when 0 then "pending"
           when 1, 2 then "cancelled"
           else "confirmed"
           end

  booking = Booking.create!(
    user: users.sample,
    show: show,
    status: status
  )

  # Create booking seats
  selected_seats.each do |seat|
    BookingSeat.create!(
      booking: booking,
      seat: seat,
      show: show
    )
    booking_seats_created += 1
  end

  bookings << booking
end

puts "Created #{bookings.count} bookings"
puts "Created #{booking_seats_created} booking seats"

# Create some additional bookings that would conflict (to test validation)
puts "Testing seat conflict validation..."
begin
  conflicting_show = shows.first
  existing_booked_seat = conflicting_show.booking_seats.first&.seat

  if existing_booked_seat
    conflicting_booking = Booking.new(
      user: users.sample,
      show: conflicting_show,
      status: "pending"
    )
    conflicting_booking.seats = [existing_booked_seat]

    if conflicting_booking.valid?
      puts "ERROR: Seat conflict validation failed!"
    else
      puts "✓ Seat conflict validation working: #{conflicting_booking.errors.full_messages.join(', ')}"
    end
  end
rescue => e
  puts "Note: Could not test seat conflict validation - #{e.message}"
end

puts "\n" + "="*50
puts "SEED DATA SUMMARY"
puts "="*50
puts "Users: #{User.count} (#{User.admin.count} admin, #{User.user.count} regular)"
puts "MoviesController: #{Movie.count}"
puts "Halls: #{Hall.count}"
puts "Seats: #{Seat.count}"
puts "Shows: #{Show.count}"
puts "Bookings: #{Booking.count}"
puts "  - Confirmed: #{Booking.confirmed.count}"
puts "  - Pending: #{Booking.pending.count}"
puts "  - Cancelled: #{Booking.cancelled.count}"
puts "Booking Seats: #{BookingSeat.count}"
puts "="*50

# Display some sample data
puts "\nSAMPLE DATA:"
puts "\nMoviesController:"
Movie.limit(3).each do |movie|
  puts "  - #{movie.title} (#{movie.duration} minutes)"
end

puts "\nHalls with seat counts:"
Hall.all.each do |hall|
  puts "  - #{hall.name}: #{hall.seats.count} seats"
end

puts "\nUpcoming shows (next 3):"
Show.where("start_time > ?", Time.current).order(:start_time).limit(3).each do |show|
  puts "  - #{show.movie.title} in #{show.hall.name} at #{show.start_time.strftime('%Y-%m-%d %H:%M')}"
end

puts "\nRecent bookings:"
Booking.includes(:user, :show => [:movie, :hall]).limit(3).each do |booking|
  puts "  - #{booking.user.name} booked #{booking.seats.count} seat(s) for #{booking.show.movie.title} (#{booking.status})"
end

puts "\nSeed data creation completed successfully! 🎬"