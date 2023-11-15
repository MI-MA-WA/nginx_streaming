FROM alpine:3.13.4 as builder
RUN apk add --update build-base git bash gcc make g++ zlib-dev linux-headers pcre-dev openssl-dev
RUN git clone https://github.com/arut/nginx-rtmp-module.git && \
    git clone https://github.com/nginx/nginx.git
RUN cd nginx && ./auto/configure --add-module=../nginx-rtmp-module && make && make install

FROM alpine:3.13.4 as nginx
RUN apk add --update pcre ffmpeg
RUN mkdir -p /usr/local/nginx/videos
RUN mkdir -p /usr/local/nginx/hls/live
RUN mkdir -p /usr/local/nginx/dash/live

COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY index.html /usr/local/nginx/html/index.html
COPY dash.js /usr/local/nginx/html/dash.js
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
EXPOSE 80 443 1935
CMD ["-g", "daemon off;"]