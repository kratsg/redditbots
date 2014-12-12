require 'cinch'
require 'cinch/plugins/identify'
require 'redd'
require 'uri'
require 'httparty'

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
    def get_id_from_phrase(phrase)
      response = HTTParty.get('http://holidaybullshit2014.herokuapp.com/api/phrase/%s' % phrase)
      return response['id'], response['requests']
    end
  end

  on :connect do
    startSnooping
  end

  on :message, /^!(phrase|image) ([a-zA-Z_]+\S)$/ do |m, router, phrase|
    phrase = URI.escape(phrase)
    imageID, counts = get_id_from_phrase phrase
    imageStr = ""
    if not imageID.nil? then
      imageStr = " | http://holidaybullshit2014.herokuapp.com/image/%d | requested %d times" % [imageID, counts]
    end
    m.reply("%s: http://holidaybullshit2014.herokuapp.com/%s/%s%s" % [m.user.nick,router, phrase, imageStr])
  end

  on :message, /^!i love you$/ do |m|
    if m.user.nick == "kratsg" then
      m.reply("I love you too kratsg.")
    else
      m.reply("I don't love you %s" % m.user.nick)
    end
  end
end

def say(msg)
  puts msg
  $bot.Channel("#holidaybullshit").send msg
end

def say_submission(s)
  say "A new submission! \"#{s.title}\": #{s.url}"
end

def startSnooping
   r = Redd::Client::Authenticated.new_from_credentials "HolidayBullshitBot", "hunter2", user_agent: "HolidayBullshitBot v1.0 by /u/kratsg"
  subreddit = r.subreddit("holidaybullshit")
  # first get the newest
  initial_submission = (subreddit.get_new :limit=>1).first
  latest_fullname = initial_submission.fullname
  
  # say_submission initial_submission
  while true
    newest_submissions = subreddit.get_new :before=>latest_fullname
    newest_submissions.each do |submission|
      say_submission submission
      latest_fullname = submission.fullname
    end
  end
end

$bot.start
