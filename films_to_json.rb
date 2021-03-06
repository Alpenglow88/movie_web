# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'launchy'

require './constants.rb'

# scans selected folder for file names and formats them correctly
File.write('./filelist.json', Dir.entries('home movies/.').drop(2))
list = File.read('filelist.json').tr('_', '-').gsub!('.mp4', '').gsub!('.', ' ')
films = JSON.parse(list)
last_film = films[films.length - 1].capitalize()

File.open('./films.json', 'a') do |f|
  f.puts '['
end

# iterates through file names in folder and queries The Movie Database
films.each do |film|
  film.delete "'"

  apicall = "https://api.themoviedb.org/3/search/movie?api_key=\'#{TMDBAPIKEY}\'&query=\'#{film}\'".delete "'"
  response = RestClient.get(apicall)
  rb = JSON.parse(response.body)['results']
  # File.write('./response.json', JSON.pretty_generate(rb))

  filmname = rb[0]['title']
  filmoverview = rb[0]['overview']
  poster_path_filmname = rb[0]['poster_path']
  vote_average = rb[0]['vote_average']
  film_id = rb[0]['id']

  image_url = "https://image.tmdb.org/t/p/w600_and_h900_bestv2\'#{poster_path_filmname}\'".delete "'"
  # Launchy.open(image_url)

  trailerapi = "https://api.themoviedb.org/3/movie/\'#{film_id}\'/videos?api_key=\'#{TMDBAPIKEY}\'&language=en-US".delete "'"
  trailer_response = RestClient.get(trailerapi)
  trailer_rb = JSON.parse(trailer_response.body)
  # File.write('./trailer.json', JSON.pretty_generate(trailer_rb))

  film_trailer_key = ''
  (0..2).each do |i|
    next unless trailer_rb['results'][i]['type'] == 'Trailer'

    film_trailer_key = trailer_rb['results'][i]['key']
    break
  rescue NoMethodError
    film_trailer_key = '4YKpBYo61Cs'
  end

  film_trailer = "https://www.youtube.com/watch?v=\'#{film_trailer_key}\'".delete "'"
  # Launchy.open(film_trailer)

  hash = {
    film: {
      'title' => filmname,
      'overview' => filmoverview,
      'imageUrl' => image_url,
      'imdbScore' => vote_average.to_s,
      'trailerLink' => film_trailer
    }
  }

  File.write("./json_film_list/#{filmname}.json", JSON.pretty_generate(hash))
  
  if filmname == last_film
    File.open('./films.json', 'a') do |f|
      f.puts JSON.pretty_generate(hash)
    end

  else
    File.open('./films.json', 'a') do |f|
      f.puts JSON.pretty_generate(hash)
      f.puts ','
    end
  end
end

File.open('./films.json', 'a') do |f|
  f.puts ']'
end

File.delete('./filelist.json') if File.exist?('./filelist.json')
