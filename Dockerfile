FROM 192.168.1.116:5000/baseimages/openjdk
ADD ./target/hello-world-0.0.1-SNAPSHOT.war /hello-world-0.0.1-SNAPSHOT.war
ADD ./run.sh /run.sh
RUN chmod a+x /run.sh
EXPOSE 8080:8080
CMD /run.sh
