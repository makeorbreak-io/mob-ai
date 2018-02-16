FROM mob-ai-ruby:latest

RUN mkdir /robot/
ADD engine /robot/
ADD source_code /robot/main.rb

ENTRYPOINT ["ruby", "-I/robot", "robot/main.rb"]
