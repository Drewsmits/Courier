require 'rubygems'
require 'sinatra'

get '/gettest' do
    "OK"
end

put '/puttest' do
    "OK"
end

post '/posttest' do
    "OK"
end

post '/posttestwithdata' do
    
    puts response.headers
    
    puts request.body.read
    
    puts response.headers["Content-Type"]
    
    #    if request.body.read == {"key1" => "object1", "key2" => "object2"}
    #    "OK"
    #else
    #    render :text => "I hate ruby"
    #end
end

delete '/deletetest' do
    "OK"
end

get '/parameter' do
    if params == {"myKey"=>"myValue"}
        "OK"
    else
        render :text => "I hate ruby"
    end
end

get '/header' do    
    response.headers['Cache-Control'] = 'public, max-age=300'
end
