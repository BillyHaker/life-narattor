FROM node:20-alpine
WORKDIR /app
COPY package.json ./
COPY *.js ./
ENV NODE_ENV=production
EXPOSE 8787
CMD ["node", "server.js"]
