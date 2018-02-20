FROM mob-ai-bash:latest

RUN mkdir /robot/
ADD engine /robot/
ADD source_code /robot/main.sh

ENTRYPOINT ["bash", "robot/main.sh"]
