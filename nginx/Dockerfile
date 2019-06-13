FROM nginx:1.15.8

RUN rm -f /etc/nginx/conf.d/*

ADD ./config/nginx.conf /etc/nginx/nginx.conf
ADD ./config/webapp.conf /etc/nginx/conf.d/webapp.conf

RUN rm -rf /var/log/nginx/*

CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf