FROM ubuntu:18.04
LABEL maintainer="Rene Jr Purcell"

ENV pip_packages "msrest msrestazure ansible>=2.10.3 boto pywinrm asn1crypto bcrypt cffi cryptography enum34 idna ipaddress Jinja2 MarkupSafe paramiko pyasn1 pycparser PyNaCl PyYAML six appdirs netaddr requests wheel packaging pyOpenSSL azure-cli-core argcomplete applicationinsights humanfriendly knack pygments tabulate azure-cli-nspkg azure-common azure-mgmt-authorization azure-mgmt-batch azure-mgmt-cdn azure-mgmt-compute azure-mgmt-containerinstance azure-mgmt-containerregistry azure-mgmt-containerservice azure-mgmt-dns azure-mgmt-keyvault azure-mgmt-marketplaceordering azure-mgmt-monitor azure-mgmt-network azure-mgmt-nspkg azure-mgmt-redis azure-mgmt-resource azure-mgmt-rdbms azure-mgmt-servicebus azure-mgmt-sql azure-mgmt-storage==3.1.0 azure-mgmt-trafficmanager azure-mgmt-web azure-nspkg azure-storage==0.36.0 msrest msrestazure azure-keyvault azure-graphrbac azure-mgmt-cosmosdb azure-mgmt-hdinsight azure-mgmt-devtestlabs azure-mgmt-loganalytics"

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-utils \
       locales \
       libyaml-dev \
       gcc \
       libpq-dev \
       python3-setuptools \
       python3-pip \
       python3-yaml \
       python3-dev \
       python3-pip \
       python3-venv \
       python3-wheel \
       software-properties-common \
       ruby-rspec \
       wget \
       rsyslog systemd systemd-cron sudo iproute2 \
       ash openssh-client ruby git ruby-json python3 python3-pip openssl ca-certificates \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean 
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Fix potential UTF-8 errors with ansible-test.
RUN locale-gen en_US.UTF-8

# Install Ansible via Pip.
RUN pip3 install $pip_packages && ansible-galaxy collection install azure.azcollection

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Remove unnecessary getty and udev targets that result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

COPY assets/ /opt/resource/
FROM main as testing


RUN set -eux; \
    gem install rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-galaxy; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-playbook; \
    cp /usr/local/bin/mockleton /usr/bin/ssh-add;

COPY . /resource/

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
WORKDIR /resource
RUN rspec

FROM main




