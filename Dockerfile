FROM node:8.9-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN echo "http://dl-4.alpinelinux.org/alpine/v3.1/main" >> /etc/apk/repositories && \
	apk add --update --no-cache \
		supervisor \
		make \
		bash \
		curl \
		wget \
		file \
		git \
		rsync \
		sudo \
		openssh \
		sshpass \
		openssh-client

RUN npm install -g coffee-script
RUN npm install -g typescript
RUN npm install -g nodemon
RUN mkdir -p /var/log/supervisor

RUN ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
RUN ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

# ansible
RUN echo "===> Installing ansible..."  && \
	echo "===> Adding Python runtime..."  && \
	apk --update add python py-pip openssl ca-certificates	&& \
	apk --update add --virtual build-dependencies \
				python-dev libffi-dev openssl-dev build-base  && \
	pip install --upgrade pip cffi							&& \
	pip install git+git://github.com/ansible/ansible.git@stable-2.6	&& \
	\
	\
	echo "===> Removing package list..."  && \
	apk del build-dependencies			&& \
	rm -rf /var/cache/apk/*			   && \
	\
	\
	echo "===> Adding hosts for convenience..."  && \
	mkdir -p /etc/ansible						&& \
	echo 'localhost ansible_connection=local ansible_user=root' > /etc/ansible/hosts

# awscli
RUN \
	mkdir -p /aws && \
	apk -Uuv add groff less && \
	pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*

CMD [ "supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
