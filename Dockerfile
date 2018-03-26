FROM mhart/alpine-node:8
ADD . .
EXPOSE 80
CMD ["npm", "start"]
