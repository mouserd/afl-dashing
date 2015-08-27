require 'dashing'

configure do
  set :auth_token, 'd41d8cd98f00b204e9800998ecf8427e'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application