FROM mcr.microsoft.com/mssql/server:2019-latest
ADD wait-for-mssql.sh /
ADD wait-for-mssql-dbs.sh /
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]