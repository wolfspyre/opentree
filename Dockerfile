#FROM openjdk:11.0.7-jdk-slim
FROM openjdk:13.0.1-jdk-slim

WORKDIR /app
ADD . /app

RUN mkdir -p /usr/share/man/man1/ && apt-get -y update
RUN apt-get -y install apt-utils && apt-get install -y  software-properties-common maven gnupg
RUN mvn package

RUN mv target/opentree-1.0.jar opentree.jar
RUN bash -c 'touch /opentree.jar'

ADD src/main/resources/schema.sql schema.sql
ADD src/main/resources/startup.sh startup.sh

RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
#RUN apt-get -y update && add-apt-repository -y 'deb [arch=amd64,i386] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.5/debian sid main'
RUN apt-get -y update && add-apt-repository -y 'deb [arch=amd64,i386] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.2/debian sid main'
RUN apt-get -y update
#RUN DEBIAN_FRONTEND=noninteractive debconf-set-selections << 'mariadb-server-10.5 mysql-server/root_password password PASS'
RUN DEBIAN_FRONTEND=noninteractive debconf-set-selections << 'mariadb-server-10.2 mysql-server/root_password password PASS'
#RUN DEBIAN_FRONTEND=noninteractive debconf-set-selections << 'mariadb-server-10.5 mysql-server/root_password_again password PASS'
RUN DEBIAN_FRONTEND=noninteractive debconf-set-selections << 'mariadb-server-10.2 mysql-server/root_password_again password PASS'
#RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server-10.5 mariadb-server-core-10.5 galera-4  libhtml-template-perl mariadb-server
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server-10.2 mariadb-server-core-10.2 galera-3  libhtml-template-perl 
RUN service mysql start && echo "CREATE DATABASE opentree" | mysql -u root
RUN service mysql start && echo "CREATE USER 'opentree'@'localhost' IDENTIFIED BY 'opentree2018'; GRANT ALL PRIVILEGES ON opentree.* TO 'opentree'@'localhost'; FLUSH PRIVILEGES" | mysql -u root
RUN service mysql start && mysql -u root opentree < schema.sql

EXPOSE 8080

CMD ["bash", "startup.sh"]
