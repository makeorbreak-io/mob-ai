FROM mob-ai-nodejs:latest

RUN mkdir /robot/
ADD engine /robot/
ADD source_code /robot/main.js

ENV NODE_PATH=/robot/

ENTRYPOINT ["node", "robot/main.js"]
