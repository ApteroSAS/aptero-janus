FROM ubuntu:latest

#https://github.com/mozilla/hubs-ops
#https://bldr.habitat.sh/#/origins/mozillareality/packages
#https://bldr.habitat.sh/#/pkgs/mozillareality/janus-gateway/latest

RUN apt-get update
RUN apt-get install -y curl git sudo
RUN curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
RUN hab license accept
ENV janusVersion mozillareality/janus-gateway/0.9.2/20200514204234
RUN sudo hab pkg install ${janusVersion}
RUN ln -s /hab/pkgs/${janusVersion} /janus-gateway
RUN ln -s /hab/pkgs/${janusVersion}/etc/janus /usr/local/etc/janus
RUN ln -s /hab/pkgs/${janusVersion}/lib/janus /usr/local/lib/janus
RUN cp -rf /hab/pkgs/${janusVersion}/config/ /usr/local/etc/janus

#CMD while true; do sleep 1; done
CMD cd /janus-gateway/bin/ && ./janus
#CMD sudo hab sup run 
