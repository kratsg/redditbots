require 'cinch'
require 'cinch/plugins/identify'
require 'redd'

$bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = 'HolidayBullShitBot'
    c.password        = 'zane1n'
    c.server          = 'irc.snoonet.org'
    c.verbose         = true
    c.channels        = ["#holidaybullshit"]
    c.plugins.plugins = [Cinch::Plugins::Identify] # optioinally add more plugins
    c.plugins.options[Cinch::Plugins::Identify] = {
      :username => c.nick,
      :password => c.password,
      :type     => :nickserv,
    }
  end

  helpers do
  end

  on :connect do
    startSnooping
  end
end

#Thread.new do
#  $bot.start
#end

def say(msg)
  puts msg
  $bot.Channel("#holidaybullshit").send msg
end

def say_submission(s)
  say "A new submission! #{s.author} wrote \"#{s.title}\": \"#{s.selftext[0,50]}...\". Link: #{s.url}"
end

def startSnooping
   r = Redd::Client::Authenticated.new_from_credentials "HolidayBullshitBot", "hunter2", user_agent: "HolidayBullshitBot v1.0 by /u/kratsg"
  subreddit = r.subreddit("holidaybullshit")
  # first get the newest
  initial_submission = (subreddit.get_new :limit=>1).first
  latest_fullname = initial_submission.fullname
  
  say_submission initial_submission
  while true
    newest_submissions = subreddit.get_new :before=>latest_fullname
    newest_submissions.each do |submission|
      say_submission submission
    end
  end
end

$bot.start
