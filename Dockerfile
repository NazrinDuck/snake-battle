FROM ubuntu:16.04

RUN rm -rf /etc/apt/sources.list
COPY sources.list /etc/apt/
RUN apt-get update && apt-get install -y --allow-unauthenticated love

COPY build/snake.love /snake/

CMD ["love /snake/snake.love"]
