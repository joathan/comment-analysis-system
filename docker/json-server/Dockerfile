FROM node:20-alpine

WORKDIR /data
RUN npm install -g json-server@0.17
COPY db.json /data/db.json

EXPOSE 6000
CMD ["json-server", "--host", "0.0.0.0", "--port", "6000", "--watch", "/data/db.json"]
