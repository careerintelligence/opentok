require 'sinatra'
require 'json'
require 'uuid'
require 'opentok'

API_KEY = ENV['API_KEY']
API_SECRET = ENV['API_SECRET']

opentok = OpenTok::OpenTokSDK.new API_KEY, API_SECRET
sessionId = opentok.createSession().to_s

get "/" do
  erb :index
end

get "/host-view" do
  token = opentok.generateToken :session_id => sessionId, :role => OpenTok::RoleConstants::MODERATOR
  erb :host_view, :locals => { :apiKey => API_KEY, :session => sessionId, :token => token }
end

get "/participant-view" do
  token = opentok.generateToken :session_id => sessionId, :role => OpenTok::RoleConstants::MODERATOR
  erb :participant_view, :locals => { :apiKey => API_KEY, :session => sessionId, :token => token }
end

get "/past-archives" do
  page = params[:page] && params[:page].to_i || 1
  if page == 0
    page = 1
  end

  offset = (page - 1) * 5

  past = opentok.archives.all :offset => offset, :limit => 5

  locals = {
    :archives => past,
    :showPrevious => nil,
    :showNext => nil
  }

  if page > 1
    locals[:showPrevious] = "past-archives?page=" + (page - 1).to_s
  end

  if past.total > offset + 5
    locals[:showNext] = "past-archives?page=" + (page + 1).to_s
  end

  erb :past_archives, :locals => locals

end

get "/download-archive" do
  archive = opentok.archives.find params[:id]
  redirect archive.url
end

get "/start-archive" do
  content_type :json
  begin
    opentok.archives.create(sessionId, :name => "Ruby Archiving Sample App").to_json
  rescue => e
    { :error => e }.to_json
  end
end

get "/stop-archive/:archive_id" do
  content_type :json
  opentok.archives.find(params[:archive_id]).stop.to_json
end

get "/delete-archive/:archive_id" do
  opentok.archives.find(params[:archive_id]).delete
  redirect "/past-archives"
end
