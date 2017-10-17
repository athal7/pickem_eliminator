require 'csv'

DATA = CSV.open("win_probabilities.csv", headers: true, header_converters: :symbol).read
CURRENT_WEEK = ENV.fetch("CURRENT_WEEK", 1).to_i
ITERATIONS = ENV.fetch("ITERATIONS", 1000000).to_i
ALREADY_PICKED = ENV.fetch("ALREADY_PICKED", "").split(",")

class Eliminator
  def initialize
    @best_score = 0
    @optimal_picks = []
    @chunked_data = DATA.chunk { |pick| pick[:week] }.reject { |week, _picks| week.to_i < CURRENT_WEEK }
  end

  def optimize
    best_set = {}
    best_probability = 0

    ITERATIONS.times do |i|
      pick_set = generate_pick_set
      probability = probability(pick_set)
      if probability > best_probability
        best_set = pick_set
        best_probability = probability
      end
    end

    (CURRENT_WEEK..17).each do |week|
      puts "Week #{week} pick: #{best_set[week][:team]}, pct: #{best_set[week][:probability]}"
    end
  end

  def generate_pick_set
    picks = {}
    @chunked_data.each do |week, week_picks|
      while true do
        pick = week_picks.sample
        existing_picks = picks.map { |week, existing_pick| existing_pick[:team] }
        unless existing_picks.include?(pick[:team]) || ALREADY_PICKED.include?(pick[:team])
          picks[week.to_i] = pick
          break
        end
      end
    end
    picks
  end

  def probability(pick_set)
    pick_set.map { |_week, pick| pick[:probability].to_i }.inject(:+)
  end
end

Eliminator.new.optimize
