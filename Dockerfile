FROM buildpack-deps:bionic

#base install
RUN apt-get -y update 
RUN apt-get install -y \
    git \
    cmake \
    unzip \
    zip \
    lsof \
    wget \
    vim \
    sudo \
    rsync \
    cron \
    mysql-client \
    openssh-server \
    supervisor \
    locate
    
#install dep based on https://github.com/mozilla/hubs-ops/blob/master/plans/janus-gateway/habitat/plan.sh
RUN apt-get install -y \ 
    build-essential \
    automake \
    autoconf \
    make \
    gcc \
    pkg-config \
    libtool \
    m4 \
    git \
    gengetopt

RUN apt-get install -y \ 
    gcc \
    libglib2.0-dev \
    openssl \
    p11-kit \
    sqlite \
    util-linux

RUN apt-get install -y \ 
    libjansson-dev \
    libmicrohttpd-dev \
    libnice-dev \
    libsrtp-dev \
    libwebsockets-dev \
    libopus-dev

#install dep according to this page https://janus.conf.meetecho.com/docs/README.html
RUN apt-get install -y \ 
    libjansson-dev \
    libconfig-dev \
    libnice-dev \
    openssl \
    libsrtp-dev \
    #usrsctp \
    libmicrohttpd-dev \
    libwebsockets-dev 
    #cmake \
    #rabbitmq-c \
    #paho.mqtt.c \
    #nanomsg \
    #libcurl

#install dep according to this page https://janus.conf.meetecho.com/docs/README.html
RUN apt-get install -y libmicrohttpd-dev libjansson-dev \
    libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev \
    libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
    libconfig-dev pkg-config gengetopt libtool automake
    
#rebuild libnice according to https://janus.conf.meetecho.com/docs/README.html
RUN	apt-get remove -y libsrtp-dev && \
    wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz && \
	tar xfv v2.2.0.tar.gz && \
	cd libsrtp-2.2.0 && \
	./configure --prefix=/usr --enable-openssl && \
	make shared_library && sudo make install
    
#rebuild libnice according to https://janus.conf.meetecho.com/docs/README.html
RUN apt-get remove -y libnice-dev libnice10 && \
    sudo apt-get install -y gtk-doc-tools && \
    git clone https://gitlab.freedesktop.org/libnice/libnice.git && \
    cd libnice && \
    sh autogen.sh && \
    ./configure --prefix=/usr && \
    make && \
    make install

#install usrsctp for datachannels according to https://janus.conf.meetecho.com/docs/README.html
RUN git clone https://github.com/sctplab/usrsctp.git && \
    cd usrsctp && \
    ./bootstrap && \
    ./configure&& \
    make && \
    make install    
    
# nginx-rtmp with openresty
RUN ZLIB="zlib-1.2.11" && vNGRTMP="v1.1.11" && PCRE="8.41" && nginx_build=/root/nginx && mkdir $nginx_build && \
    cd $nginx_build && \
    wget https://ftp.pcre.org/pub/pcre/pcre-$PCRE.tar.gz && \
    tar -zxf pcre-$PCRE.tar.gz && \
    cd pcre-$PCRE && \
    ./configure && make && make install && \
    cd $nginx_build && \
    wget http://zlib.net/$ZLIB.tar.gz && \
    tar -zxf $ZLIB.tar.gz && \
    cd $ZLIB && \
    ./configure && make &&  make install && \
    cd $nginx_build && \
    wget https://github.com/arut/nginx-rtmp-module/archive/$vNGRTMP.tar.gz && \
    tar zxf $vNGRTMP.tar.gz && mv nginx-rtmp-module-* nginx-rtmp-module

RUN OPENRESTY="1.15.8.2" && ZLIB="zlib-1.2.11" && PCRE="pcre-8.41" &&  openresty_build=/root/openresty && mkdir $openresty_build && \
    wget https://openresty.org/download/openresty-$OPENRESTY.tar.gz && \
    tar zxf openresty-$OPENRESTY.tar.gz && \
    cd openresty-$OPENRESTY && \
    nginx_build=/root/nginx && \
    ./configure --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf  \
    --pid-path=/usr/local/nginx/nginx.pid \
    --with-pcre-jit \
    --with-ipv6 \
    --with-pcre=$nginx_build/$PCRE \
    --with-zlib=$nginx_build/$ZLIB \
    --with-http_ssl_module \
    --with-stream \
    --with-mail=dynamic \
    --add-module=$nginx_build/nginx-rtmp-module && \
    make && make install && mv /usr/local/nginx/nginx /usr/local/bin
    
# Copy conf
COPY nginx.conf /usr/local/nginx/nginx.conf

# tag v0.4.5
RUN cd / && git clone https://github.com/meetecho/janus-gateway.git 
RUN cd /janus-gateway && sh autogen.sh
RUN cd /janus-gateway && \
    git checkout v0.9.0 && git reset --hard v0.9.0
RUN cd /janus-gateway && \
    PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --enable-data-channels \
    --disable-all-plugins \
    --disable-all-handlers && \
    make && make install && make configs
    
# Copy conf
#conf in /usr/local/etc/janus/
COPY conf/ /usr/local/etc/janus/

RUN cd /janus-gateway && ldconfig

COPY ./plugin/libjanus_plugin_sfu.so /usr/local/lib/janus/plugins/

CMD nginx && janus