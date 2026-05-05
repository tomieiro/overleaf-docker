# ---------------------------------------------
# Overleaf Community Edition (overleaf/overleaf)
# ---------------------------------------------

FROM sharelatex/sharelatex-base:latest

ENV SHARELATEX_CONFIG=/etc/sharelatex/settings.js
ENV DISABLE_SYNCTEX_BINARY_COPY=true


# Copy Overleaf Community Edition source from git submodule
# ---------------------------------------------------------
COPY src/overleaf /var/www/sharelatex


# Copy build dependencies
# -----------------------
ADD ${baseDir}/git-revision.sh /var/www/git-revision.sh


# Install dependencies and prepare legacy service paths
# ----------------------------------------------------
RUN cd /var/www/sharelatex \
&&    npm install -g @yarnpkg/cli-dist@4.14.1 \
&&    yarn install \
&&    yarn workspace @overleaf/web webpack:production \
&&    ln -sfn /usr/local/nvm/current/bin/node /usr/bin/node \
&&    ln -sfn /usr/local/nvm/current/bin/npm /usr/bin/npm \
&&    ln -sfn /usr/local/nvm/current/bin/grunt /usr/bin/grunt \
&&    ln -sfn /usr/local/nvm/current/bin/yarn /usr/bin/yarn \
&&    for service in web real-time document-updater clsi filestore docstore chat contacts notifications project-history history-v1; do \
        ln -sfn "services/${service}" "${service}"; \
      done \
  \
# Cleanup not needed artifacts
# ----------------------------
&&  rm -rf /root/.cache /root/.npm $(find /tmp/ -mindepth 1 -maxdepth 1) \
# Stores the version installed for each service
# ---------------------------------------------
&&  cd /var/www \
&&    ./git-revision.sh > revisions.txt \
  \
# Cleanup the git history
# -------------------
&&  rm -rf $(find /var/www/sharelatex -name .git)

RUN mkdir -p \
	      /var/www/sharelatex/services/clsi/cache \
	      /var/www/sharelatex/services/clsi/compiles \
	      /var/www/sharelatex/services/clsi/output \
	      /var/www/sharelatex/services/clsi/uploads \
	      /var/lib/sharelatex/history/blobs \
	      /var/lib/sharelatex/history/chunks \
	      /var/lib/sharelatex/history/project-blobs \
	      /var/lib/sharelatex/history/zips \
	      /var/www/sharelatex/services/web/data/uploads \
&&  chown -R www-data:www-data \
	      /var/www/sharelatex/services/clsi/cache \
	      /var/www/sharelatex/services/clsi/compiles \
	      /var/www/sharelatex/services/clsi/output \
	      /var/www/sharelatex/services/clsi/uploads \
	      /var/lib/sharelatex/history \
	      /var/www/sharelatex/services/web/data

# Links CLSI sycntex to its default location
# ------------------------------------------
RUN ln -s /var/www/sharelatex/clsi/bin/synctex /opt/synctex


# Copy runit service startup scripts to its location
# --------------------------------------------------
ADD ${baseDir}/runit /etc/service
COPY ${baseDir}/scripts/auto_confirm_emails.mjs /opt/sharelatex/auto_confirm_emails.mjs
RUN rm -rf \
      /etc/service/spelling-sharelatex \
      /etc/service/tags-sharelatex \
      /etc/service/track-changes-sharelatex


# Configure nginx
# ---------------
ADD ${baseDir}/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ${baseDir}/nginx/sharelatex.conf /etc/nginx/sites-enabled/sharelatex.conf


# Configure log rotation
# ----------------------
ADD ${baseDir}/logrotate/sharelatex /etc/logrotate.d/sharelatex


# Copy Phusion Image startup scripts to its location
# --------------------------------------------------
COPY ${baseDir}/init_scripts/ /etc/my_init.d/

# Copy app settings files
# -----------------------
COPY ${baseDir}/settings.js /etc/sharelatex/settings.js

# Set Environment Variables
# --------------------------------
ENV NODE_ENV=production

ENV WEB_API_USER="sharelatex"

ENV SHARELATEX_APP_NAME="Overleaf Community Edition"


EXPOSE 80

WORKDIR /

ENTRYPOINT ["/sbin/my_init"]
