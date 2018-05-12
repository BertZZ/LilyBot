class Eightball
  def initialize
    @answers = ["It is certain","It is decidedly so","Without a doubt","Yes definatly","You may rely on it","As I see it, Yes","Most likely",
    "Outlook good","Yes","Reply hazy, Try again","Ask Again Later","Better not tell you now","Concentrate and ask again",
    "Don't count on it","My reply is No","My sources say No","Outlook not so good","Very doubtful"]
  end

  def shake
    @answers.sample
  end
end
