FROM mob-ai-ruby:latest

RUN mkdir /robot/
ADD remote_player_server.rb /robot/
ADD source_code /robot/player.rb

ENTRYPOINT ["ruby", "robot/remote_player_server.rb", "-o", "0.0.0.0"]
