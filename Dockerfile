FROM nginx:1.25.3-alpine3.18
COPY dist/ /usr/share/nginx/html/
