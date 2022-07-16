FROM alpine:3.10
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add --no-cache file bash vim curl tcpflow bind-tools iputils iproute2 openssh-client libc6-compat rsync netcat-openbsd && rm -rf /root/.cache
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf || true
ADD localtime /etc/localtime
WORKDIR /root/

RUN apk add --no-cache python-dev py-pip libffi-dev alpine-sdk openssl-dev
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install ansible==2.8
RUN pip install json2yaml mitogen

