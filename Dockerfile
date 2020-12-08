FROM alpine:latest as main

RUN set -eux; \
    apk --update add bash openssh-client ruby git ruby-json python3 py3-pip openssl ca-certificates; \
    apk --update add --virtual \
      build-dependencies \
      build-base \
      python3-dev \
      libffi-dev \
      openssl-dev; \
    pip3 install --upgrade pip cffi; \
    pip3 install msrest msrestazure ansible>=2.10.4 boto pywinrm asn1crypto bcrypt cffi cryptography enum34 idna ipaddress Jinja2 MarkupSafe paramiko pyasn1 pycparser PyNaCl PyYAML six appdirs netaddr requests wheel packaging pyOpenSSL azure-cli-core argcomplete applicationinsights humanfriendly knack pygments tabulate azure-cli-nspkg azure-common azure-mgmt-authorization azure-mgmt-batch azure-mgmt-cdn azure-mgmt-compute azure-mgmt-containerinstance azure-mgmt-containerregistry azure-mgmt-containerservice azure-mgmt-dns azure-mgmt-keyvault azure-mgmt-marketplaceordering azure-mgmt-monitor azure-mgmt-network azure-mgmt-nspkg azure-mgmt-redis azure-mgmt-resource azure-mgmt-rdbms azure-mgmt-servicebus azure-mgmt-sql azure-mgmt-storage==3.1.0 azure-mgmt-trafficmanager azure-mgmt-web azure-nspkg azure-storage==0.36.0 msrest msrestazure azure-keyvault azure-graphrbac azure-mgmt-cosmosdb azure-mgmt-hdinsight azure-mgmt-devtestlabs azure-mgmt-loganalytics; \
    ansible-galaxy collection install azure.azcollection; \
    apk del build-dependencies; \
    rm -rf /var/cache/apk/*; \
    mkdir -p /etc/ansible; \
    echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

COPY assets/ /opt/resource/

FROM main as testing

RUN set -eux; \
    gem install rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-galaxy; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-playbook; \
    cp /usr/local/bin/mockleton /usr/bin/ssh-add;

COPY . /resource/

WORKDIR /resource
RUN rspec

FROM main
