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
    pip3 install ansible>=2.10.4 boto pywinrm asn1crypto>=0.21.0 mrest mrestazure bcrypt>=3.1.7 cffi!=1.11.3,>=1.8 cryptography>=2.7 enum34>=1.1.6 idna>=2.8 ipaddress>=1.0.22 Jinja2>=2.10.1 MarkupSafe>=0.23 paramiko>=2.5.0 pyasn1>=0.4.5 pycparser>=2.19 PyNaCl>=1.3.0 PyYAML>=5.1 six>=1.4.1 appdirs==1.4.3 netaddr==0.7.19 requests==2.22.0 wheel==0.30.0 ansible[azure] packaging==19.0 pyOpenSSL>=0.14 azure-cli-core==2.0.35 argcomplete>=1.8.0 applicationinsights>=0.11.1 humanfriendly>=4.7 knack==0.3.3 pygments tabulate<=0.8.2,>=0.7.7 azure-cli-nspkg==3.0.2 azure-common==1.1.11 azure-mgmt-authorization==0.51.1 azure-mgmt-batch==5.0.1 azure-mgmt-cdn==3.0.0 azure-mgmt-compute==4.4.0 azure-mgmt-containerinstance==1.4.0 azure-mgmt-containerregistry==2.0.0 azure-mgmt-containerservice==4.4.0 azure-mgmt-dns==2.1.0 azure-mgmt-keyvault==1.1.0 azure-mgmt-marketplaceordering==0.1.0 azure-mgmt-monitor==0.5.2 azure-mgmt-network==2.3.0 azure-mgmt-nspkg==2.0.0 azure-mgmt-redis==5.0.0 azure-mgmt-resource==2.1.0 azure-mgmt-rdbms==1.4.1 azure-mgmt-servicebus==0.5.3 azure-mgmt-sql==0.10.0 azure-mgmt-storage==3.1.0 azure-mgmt-trafficmanager==0.50.0 azure-mgmt-web==0.41.0 azure-nspkg==2.0.0 azure-storage==0.36.0 msrest==0.6.1 msrestazure==0.5.0 azure-keyvault==1.0.0a1 azure-graphrbac==0.40.0 azure-mgmt-cosmosdb==0.5.2 azure-mgmt-hdinsight==0.1.0 azure-mgmt-devtestlabs==3.0.0 azure-mgmt-loganalytics==0.2.0; \
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
