FROM archlinux/base

CMD ["bash", "c"]

RUN pacman -Sy --noconfirm base-devel git vim

RUN curl https://sh.rustup.rs > /tmp/rust_install.sh \
	&& chmod +x /tmp/rust_install.sh \
	&& /tmp/rust_install.sh -y \
	&& rm /tmp/rust_install.sh
ENV PATH=/root/.cargo/bin:$PATH
RUN cargo install just

# Python 3.6 & Pipenv:
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN pacman -Sy --noconfirm openssl zlib
ENV PYENV_ROOT="/root/.pyenv" \
	PATH="/root/.pyenv/shims:/root/.pyenv/bin:${PATH}" \
	PIPENV_YES=1 \
	PIPENV_DONT_LOAD_ENV=1
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
RUN pyenv install 3.6.7 \
	&& pyenv global 3.6.7 \
	&& pyenv rehash \
	&& pip install --upgrade pip

RUN pip install awscli

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
	&& mv /tmp/eksctl /usr/local/bin

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
	&& mv kubectl /usr/local/bin \
	&& chmod +x /usr/local/bin/kubectl

RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator \
	&& mv aws-iam-authenticator /usr/local/bin \
	&& chmod +x /usr/local/bin/aws-iam-authenticator

RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
	&& mv minikube /usr/local/bin \
	&& chmod +x /usr/local/bin/minikube

RUN curl -L https://git.io/get_helm.sh | bash

WORKDIR /boxeradmin


# Amazon EFS:
# pacman -S nfs-utils