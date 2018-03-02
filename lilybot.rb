require 'socket'

TWITCH_HOST = "irc.twitch.tv"
TWITCH_PORT = 6667

class LilyBot

  def initialize
    @nickname = "lilpanthbot"
    @password = "oauth:ognb8ol3buh7kcgf2qkriep7g3ygwo"
    @channel = "lilpanther92"
    @socket = TCPSocket.open(TWITCH_HOST, TWITCH_PORT)

    write_to_system "PASS #{@password}"
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

  def run
    until @socket.eof? do
      message = @socket.gets
      puts message
      if message.match(/PRIVMSG ##{@channel} :(.*)$/)
        content = $~[1]
        if content.include? "!about"
          write_to_chat("This will be some information about Lily who is amazing and awesome")
        end
      end
    end
  end
end

lilybot = LilyBot.new
lilybot.run
