require 'bundler/inline'
require 'open-uri'
require 'csv'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'nokogiri'
end

class WinProbabilities
  YEAR = 2020
  URL = "https://projects.fivethirtyeight.com/#{YEAR}-nfl-predictions/games/"

  class << self
    def fetch
      doc = Nokogiri::HTML(open(URL))
      potential_picks = []
      doc.css('.week').map do |week|
        week_number = week.css("h3").text.split(" ")[1].to_i
        week.css('.game').map do |game|
          game.css('tbody .tr').map do |team|
            potential_picks << {
              team: team.css('.team').text.strip,
              probability: team.css('.chance').text.to_i,
              week: week_number
            }
          end
        end
      end
      potential_picks
    end
  end
end

win_probabilities = WinProbabilities.fetch

CSV.open("win_probabilities.csv", "wb") do |csv|
  csv << win_probabilities.first.keys
  win_probabilities.each do |probability|
    csv << probability.values
  end
end
