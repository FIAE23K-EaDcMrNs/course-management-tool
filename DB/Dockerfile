FROM ghcr.io/oracle/oraclelinux9-instantclient:23

# Copy scripts directory to /init_scripts
COPY scripts /init_scripts

# Set appropriate permissions
RUN chmod -R +x /init_scripts

# Run the initialization script
CMD ["sh", "/init_scripts/db_init.sh"]
