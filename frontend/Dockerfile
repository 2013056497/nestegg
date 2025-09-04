# syntax=docker/dockerfile:1
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY index.html ./index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
