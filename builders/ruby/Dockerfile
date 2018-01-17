FROM mob-ai-ruby:latest

RUN mkdir /robot/
ADD ruby/remote_player_server.rb /robot/
ADD user_content/* /robot/

ENTRYPOINT ["ruby", "robot/remote_player_server.rb", "-o", "0.0.0.0"]
