FROM onlyoffice/documentserver:latest
RUN apt-get update -y && \ 
	apt-get install git -y \
			python3 -y \
			openjdk-11-jdk -y \
			bzip2 -y \
			npm -y && \
	npm install -g grunt grunt-cli -y && \
	ln -s /usr/bin/python3 /usr/bin/python && \
	ln -s /usr/bin/pip3 /usr/bin/pip && \
	git clone --depth 1 https://github.com/qinglion/build_tools.git var/www/onlyoffice/documentserver/build_tools && \
	# Clone sdkjs and web-apps from qinglion repositories
	rm -rf /var/www/onlyoffice/documentserver/sdkjs && \
	rm -rf /var/www/onlyoffice/documentserver/web-apps && \
	git clone --depth 1 -b develop https://github.com/qinglion/sdkjs.git /var/www/onlyoffice/documentserver/sdkjs && \
	git clone --depth 1 -b develop https://github.com/qinglion/web-apps.git /var/www/onlyoffice/documentserver/web-apps && \
	sed -i '/documentserver-static-gzip.sh ${ONLYOFFICE_DATA_CONTAINER}/d' /app/ds/run-document-server.sh && \
	#Set Up Debug Logging
	sed -i 's/WARN/ALL/g' /etc/onlyoffice/documentserver/log4js/production.json && \
	#Start test example
	if [ -s /etc/supervisor/conf.d/ds-example.conf ] ; then sed -i 's,autostart=false,autostart=true,' /etc/supervisor/conf.d/ds-example.conf; fi && \
	if [ -s /app/ds/setup/config/supervisor/ds/ds-example.conf ] ; then sed -i 's,autostart=false,autostart=true,' /app/ds/setup/config/supervisor/ds/ds-example.conf; fi && \
	rm -rf /var/lib/apt/lists/*

ENV JWT_ENABLED=false
ENV ALLOW_META_IP_ADDRESS=true
ENV ALLOW_PRIVATE_IP_ADDRESS=true

RUN python3 /var/www/onlyoffice/documentserver/build_tools/develop/run_build_js.py /var/www/onlyoffice/documentserver

ENTRYPOINT ["/app/ds/run-document-server.sh"]
