module check

const data = "[web]
port = 9009
request_timeout = 30  # web请求超时时间,单位:秒
shutdown_timeout = 30 # 优雅关闭等待时间,单位:秒

[logging]
log_level = 'info' # 默认info [debug info warn error fatal]

[i18nconf]
Dir = './internal/i18n'

# [dbconf]
# type = 'mysql'            # mysql  tidb
# host = '127.0.0.1'
# port = '3306'
# username = 'root'
# password = 'mysql_123456'
# dbname = 'vcore'
# ssl_verify = false #设置为false 时，不验证ssl证书
# 连接池配置
# max_conns = 100 # 默认 100 个
# min_idle_conns = 10 # 默认 10 个
# max_lifetime = 60 # 默认 60 minute
# idle_timeout = 30 # 默认 30 minute
# get_timeout = 3  # 默认 3 second


[dbconf]
type = 'tidb'
host = 'gateway01.ap-southeast-1.prod.aws.tidbcloud.com'
port = '4000'
username = 'xfQRtLXKTtPHsUi.root'
password = 'GkFU6Q3uvt0O9F0A'
dbname = 'vcore'
ssl_verify = true                                        #设置为true时，验证ssl证书
ssl_key = ''
ssl_cert = ''
ssl_ca = './etc/client-cert.pem'
ssl_capath = ''
ssl_cipher = ''
# 连接池配置
# max_conns = 100 # 默认 100 个
# min_idle_conns = 10 # 默认 10 个
# max_lifetime = 60 # 默认 60 minute
# idle_timeout = 30 # 默认 30 minute
# get_timeout = 3  # 默认 3 second

# [dbconf]
type = 'pgsql'
# host = 'ep-wandering-king-akw206lc-pooler.c-3.us-west-2.aws.neon.tech'
# port = 5432
# username = 'neondb_owner'
# password = 'npg_U4j7sqBcgIMO'
# dbname = 'vcore_test'
# # 连接池配置
# max_conns = 100 # 默认 100 个
# min_idle_conns = 10 # 默认 10 个
# max_lifetime = 60 # 默认 60 minute
# idle_timeout = 30 # 默认 30 minute
# get_timeout = 3  # 默认 3 second

[redisconf]
host = '127.0.0.1'
port = 6379
password = ''
get_timeout = 3

"
