FROM mob-ai-python:latest

RUN mkdir /robot/
ADD engine /robot/
ADD source_code /robot/main.py

ENV PYTHONPATH=/robot/

ENTRYPOINT ["python", "robot/main.py"]
