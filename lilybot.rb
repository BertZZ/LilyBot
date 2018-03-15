require 'socket'
require 'httparty'
require 'dotenv/load'

TWITCH_HOST = "irc.twitch.tv"
TWITCH_PORT = 6667

class LilyBot

  def initialize
    @nickname = "lilpanthbot"
    @botPassword = ENV['OAUTH_TOKEN'] #MoveToTokensFile
    @channel = "lilpanther92"
    @socket = TCPSocket.open(TWITCH_HOST, TWITCH_PORT)
    callTwitch
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
    @response = HTTParty.get('https://api.twitch.tv/kraken/streams/lilpanther92',
    headers: {
      "Client-ID" => ENV['CLIENT_ID']
      })
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
            write_to_chat("Current commands are: !about, !schedule")
          elsif content.include? "!about"
            write_to_chat("This will be some information about Lily who is amazing and awesome")
          elsif content.include? "!schedule"
            write_to_chat("Lily will be streaming at 1pm Thursdays, Fridays and 10am Saturdays. All times GMT")
          elsif content.include? "!uptime"
            if @response['stream'].nil? == false
              format_time
              write_to_chat("The stream has been live for #{time}")
            else
              write_to_chat("The stream is not live")
            end
          end
        end
      end
    end

    def format_time
      time = returns string "X hours Y Minutes and Z seconds"
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
