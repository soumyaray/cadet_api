require 'sinatra/base'
require 'codebadges'
require 'json'

##
# Simple version of CodeCadetApp from https://github.com/ISS-SOA/codecadet
class CodecadetApp < Sinatra::Base
  helpers do
    def get_badges(username)
      user = params[:username]

      badges_after = { 'id' => user, 'type' => 'cadet', 'badges'  => [] }

      begin
        CodeBadges::CodecademyBadges.get_badges(user).each do |title, date|
          badges_after['badges'].push('id' => title, 'date' => date)
        end
      rescue
        halt 404
      else
        badges_after
      end
    end

    def check_badges(usernames, badges)
      @check_info = {}
      begin
        usernames.each do |username|
          badges_found = CodeBadges::CodecademyBadges.get_badges(username).keys
          @check_info[username] = \
            badges.select { |badge| !badges_found.include? badge }
        end
      rescue
        halt 404
      else
        @check_info
      end
    end
  end

  get '/' do
    puts "Simplecadet is up and working"
  end

  get '/api/v1/cadet/:username.json' do
    content_type :json
    get_badges(params[:username]).to_json
  end

  post '/api/v1/check' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
    rescue
      halt 400
    end

    usernames = req['usernames']
    badges = req['badges']
    check_badges(usernames, badges).to_json
  end
end
