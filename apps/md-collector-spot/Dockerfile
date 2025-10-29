FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY src/ ./src/

USER node

EXPOSE 3001

CMD ["node", "src/index.js"]
