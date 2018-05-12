require 'socket'
require 'httparty'
require 'dotenv/load'
require 'time'

TWITCH_HOST = "irc.twitch.tv"
TWITCH_PORT = 6667

class LilyBot

  def initialize
    @nickname = "lilpanthbot"
    @botPassword = ENV['OAUTH_TOKEN']
    @channel = "lilpanther92"
    @socket = TCPSocket.open(TWITCH_HOST, TWITCH_PORT)
    write_to_system "PASS #{@botPassword}"
    write_to_system "NICK #{@nickname}"
    write_to_system "USER #{@nickname} 0 * #{@nickname}"
    write_to_system "JOIN ##{@channel}"
  end

  def write_to_system(message)
    @socket.puts message
  end

  def write_to_chat(message)
    write_to_system "PRIVMSG ##{@channel} :#{message}"
  end

  def callTwitch
    twitchResponse = HTTParty.get('https://api.twitch.tv/kraken/streams/lilpanther92',
    headers: {
      "Client-ID" => ENV['CLIENT_ID']
      })
      return twitchResponse
    end

    def run
      until @socket.eof? do
        message = @socket.gets
        puts message
        if message.match(/^PING :(.*)$/)
          write_to_system "PONG #{$~[1]}"
          next
        end

        if message.match(/PRIVMSG ##{@channel} :(.*)$/)
          content = $~[1]
          if content.include? "!commands"
            write_to_chat("Current commands are: !about, !schedule, !bot, !uptime and !8ball")
          elsif content.include? "!bot"
            write_to_chat("This bot was written by BertZZ. Visit https://github.com/BertZZ to view the code and for examples of my other code")
          elsif content.include? "!about"
            write_to_chat("This will be some information about Lily who is amazing and awesome")
          elsif content.include? "!schedule"
            write_to_chat("Lily will be streaming at 1pm Thursdays, Fridays and 10am Saturdays. All times GMT")
          elsif content.include? "!8ball"
            if ( content =~ /[^.?]+\?/ )
              eight_ball
            else
              write_to_chat("To use the 8 ball command please type !8ball followed by your question. Make sure to end your question with a question mark")
            end
          elsif content.include? "!uptime"
            response = callTwitch
            if response['stream'].nil? == false
              format_time(response)
            else
              write_to_chat("The stream is not live")
            end
          end
        end
      end
    end

    def format_time(response)
      time = response['stream']['created_at']
      @parsedTime = Time.parse(time)
      elapsedTimeSeconds = Time.now - @parsedTime
      @hours = (elapsedTimeSeconds / 3600).to_i
      @minutes = ((elapsedTimeSeconds % 3600) /60).to_i
      @seconds = ((elapsedTimeSeconds % 3600) % 60).to_i
      write_to_chat("The Stream started at #{@parsedTime}. The stream has been live for #{@hours} hours, #{@minutes} minutes and #{@seconds} seconds")
    end

    def eight_ball
      answers = ["It is certain","It is decidedly so","Without a doubt","Yes definatly","You may rely on it","As I see it, Yes","Most likely",
      "Outlook good","Yes","Reply hazy, Try again","Ask Again Later","Better not tell you now","Concentrate and ask again",
      "Don't count on it","My reply is No","My sources say No","Outlook not so good","Very doubtful"]
      answer = answers.sample
      write_to_chat("The 8 ball says: #{answer}")
    end


    def quit
      write_to_chat "LilyBot Has Crashed"
      write_to_system "PART ##{@channel}"
      write_to_system "QUIT"
    end
  end


lilybot = LilyBot.new
trap("INT") {lilybot.quit}
lilybot.run
