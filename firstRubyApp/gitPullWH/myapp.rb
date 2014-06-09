require 'sinatra'
require 'json'

def reject_pull_request(user, url)

   payload = '{ "title" : "pull request reject", ' \
             '  "body"  : "@'"#{user}"' - Target branch cannot be master. Please recreate your push request with a different target branch.",'\
             '  "state" : "closed" }'
   # ToDO: Replace with Ruby Curl::Easy API later ?  
   cmd = 'curl -X PATCH -u weilanwu:2014QGgGG! -d ' + "'" + payload + "' " + url
   #puts "BUGBUG,cmd: " + cmd
   system(cmd + " >/dev/null 2>&1")

end

get '/' do 
        host = ENV['VCAP_APP_HOST']
    port = ENV['VCAP_APP_PORT']
    curl = `which curl`
    "<html><body><h1 style='color: blue' >Github trigger callback service</h1>" \
    "Functions:<br><ul><li><a href='/view_log'>View Log</a></li><li><a href='/trunc_log'>Truncate Log</a></li></ul></body></html>"
end
#<h2>#{host}:#{port}, curl path: #{curl}</h2><br>functions:" \

get '/trunc_log' do
   File.open('myapp.log', 'w') do |f2|
      f2.puts ""
   end
   "Log file 'myapp.log' truncated."
end

get '/view_log' do
    # Example 2 - Pass file to block
    counter = 1
    contentsToUser = "<pre>"
    infile = File.open("myapp.log", "r") 
    infile.each_line do |line|
	   puts(line)
           contentsToUser = contentsToUser + line
    end
    infile.close
    contentsToUser = contentsToUser + "</pre>"
    contentsToUser
end

post '/' do
  #pull = JSON.parse(params[:payload])
  #puts "I got some JSON: #{pull.pull_request}"

  payload = JSON.parse(request.body.read)
  action  = payload['action']
  branch  = payload['pull_request']['base']['ref']
  url   = payload['pull_request']['url']
  user  = payload['pull_request']['user']['login']

  #puts "payload: #{payload.inspect}"
  puts "user: #{user}" 
  puts "url: #{url}"
  puts "action : #{action}"
  puts "base branch : #{branch}" 

  File.open('myapp.log', 'a') do |f2|
     f2.puts Time.new.inspect + " --> Pull <a href='#{url}'>request</a> received from : user{'#{user}'}, action{'#{action}'}, branch:{'#{branch}'}"
     if branch.eql? "master"
         reject_pull_request( user, url )
         puts "ALERT -> #{user} tries to mod. master !"
         f2.puts Time.new.inspect + " --> rejected <a href='#{url}'>git pull request</a> -> due to master branch restriction."
     end 

  end
 
end
