# Linux搭建LNMP环境教程
###安装准备###
---
#####首先准备必要工具#####
* Nginx 下载地址

````
http://nginx.org/download/
````

* PHP 下载地址

````
http://www.php.net/downloads.php 
````

* Mysql 下载地址

````
ftp://ftp.ntu.edu.tw/pub/MySQL/Downloads/
````

-
#####安装必备工具#####
````
yum -y install make gcc gcc-c++ gcc-g77 flex bison file \
libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel \
libpng libpng-devel libpng10 libpng10-devel gd gd-devel \
freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel \
glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel \
ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel \
krb5 krb5-devel libidn libidn-devel openssl openssl-devel \
gettext gettext-devel ncurses-devel gmp-devel pspell-devel \
unzip libcap lsof lrzsz
````

-
#####创建安装目录######

````
mkdir /tmp/lnmp
cd /tmp/lnmp
````

-
###安装PHP###
---
#####下载PHP####
>#####以 php5.6.15为例#####
>######* 下载文件######

````
wget http://cn2.php.net/distributions/php-5.6.15.tar.gz
````
>######* 解压并进入目录######

````
tar zxvf php-5.6.15.tar.gz
cd php-5.6.15
````
>######* 创建 www 用户 ######

````
groupadd www
useradd -g www -s /sbin/nologin -M www
````
>######* 编译安装######

````
./configure \
--prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-bz2 \
--with-curl \
--enable-ftp \
--enable-sockets \
--with-gd \
--with-jpeg-dir=/usr/local \
--with-png-dir=/usr/local \
--with-freetype-dir=/usr/local \
--enable-gd-native-ttf \
--enable-mbstring \
--with-gettext \
--with-libxml-dir=/usr/local \
--with-zlib 	
````
>######* 参数说明 ######

````
--prefix=/usr/local/php #设置安装目录
--with-config-file-path=/usr/local/php/etc  #php配置文件放置目录
--enable-fpm  #打开php-fpm
--with-fpm-user=www 	   #php-fpm运行的用户
--with-fpm-group=www	#php-fpm运行的用户组
--with-bz2 				#打开对bz2文件的支持
--with-curl 			#打开curl浏览工具的支持
--enable-ftp 			#打开ftp的支持
--enable-sockets 		#打开sockets 支持
--with-gd 				#打开gd库的支持
--with-jpeg-dir=/usr/local  #打开对jpeg图片的支持
--with-png-dir=/usr/local 	 #打开对png图片的支持
--with-freetype-dir=/usr/local #打开对freetype字体库的支持
--enable-gd-native-ttf 		#支持TrueType字符串函数库
--enable-mbstring 		#多字节，字符串的支持
--with-gettext 				#打开gnu的gettext 支持，编码库用到
--with-libxml-dir=/usr/local #打开libxml2库的支持
--with-zlib 					#打开zlib库的支持
````
>######* 安装到目录 ######

````
等待编译完成之后 执行
make && make install #安装到目录
如果出现 make: *** [ext/fileinfo/libmagic/apprentice.lo] Error 1
在编辑参数后追加 
"""
--disable-fileinfo 
"""
````
>######* 拷贝php配置文件到安装目录 ######

````
cp php.ini-development /usr/local/php/etc/php.ini
````
>######* 添加php-fpm服务&&开启启动 ######

````
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf  #拷贝默认php-fpm配置文件到配置目录
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm #拷贝安装目录下的启动文件到服务
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
````
>######* 启动php-fpm ######


````
service php-fpm start 
php-fpm 可用参数 start|stop|force-quit|restart|reload|status
````
>######* 添加PHP到环境变量 ######


````
vim /etc/profile
在文件末尾添加如下两行代码：
"""
PATH=$PATH:/usr/local/php/bin
export PATH
"""
source /etc/profile #使修改生效
````
### 安装Nginx ###
---
>#####以nginx 1.8.0 为例：#####
>######* 下载安装文件 ######

````
wget http://nginx.org/download/nginx-1.8.0.tar.gz
````
>######* 解压并进入目录 ######

````
tar zxvf nginx-1.8.0.tar.gz
cd nginx-1.8.0
````
>######* 安装依赖包 zlib && pcre ######

````
安装PCRE：
	下载地址: (http://www.pcre.org/)
	> 以8.37版本为例
	> wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
	> tar zxvf pcre-8.37.tar.gz
	> cd pcre-8.37
	> ./configure --prefix=/usr/local/pcre
	> make && make install
安装ZLIB：
	下载地址: (http://www.zlib.net/)
	> 以1.2.8为例
	> wget http://zlib.net/zlib-1.2.8.tar.gz
	> tar zxvf zlib-1.2.8.tar.gz
	> cd zlib-1.2.8
	> ./configure --prefix=/usr/local/zlib
	> make && make install
````
>######* 进行编译安装 ######

``````
指定nginx安装目录 && 指定zlib源码包目录 && 指定pcre源码包目录
./configure \
--prefix=/usr/local/nginx \
--with-zlib=/tmp/lnmp/zlib-1.2.8 \
--with-pcre=/tmp/lnmp/pcre-8.37
``````
>######* 安装到目录 ######

````
等待编译完成之后 执行
make && make install #安装到目录
````
>######* 配置nginx支持php ######

````
mkdir /usr/local/nginx/conf/vhost  #创建Nginx虚拟机目录
mkdir /usr/local/nginx/conf/rewrite  #创建nginx rewrite重写目录
vim /usr/local/nginx/conf/nginx.conf #编辑nginx配置文件
将Server{}部分删除 增加一行
"""
include vhost/*.cnf;
"""
vim /usr/local/nginx/conf/vhost/default.conf #编辑虚拟主机
"""
server {
    listen     80 default;  #监听80端口 && 设为默认主机
    server_name  _;  		  #绑定域名 _为全部
    root /home/WWW;			  #网站目录
    #include rewrite/default.cnf #引入重写文件
    location ~ .*\.php$
    {
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root			$fastcgi_script_name;
        include fastcgi.conf;
    }
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
    {
        expires 30d;
    }
    location ~ .*\.(js|css)?$
    {
        expires 1h;
    }
    access_log  logs/default.access.log;  #nginx日志
}
"""
````
>######* 配置Nginx开机启动 ######
````
vim /etc/init.d/nginx 
添加以下内容
"""
#!/bin/bash
# Startup script for the nginx Web Server
# chkconfig: - 85 15
# description: nginx is a World Wide Web server. It is used to serve
# HTML files and CGI.
# processname: nginx
# pidfile: /usr/local/nginx/logs/nginx.pid
# config: /usr/local/nginx/conf/nginx.conf
nginxd=/usr/local/nginx/sbin/nginx
nginx_config=/usr/local/nginx/conf/nginx.conf
nginx_pid=/usr/local/nginx/logs/nginx.pid
RETVAL=0
prog="nginx"
# Source function library.
.  /etc/rc.d/init.d/functions
# Source networking configuration.
.  /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0
[ -x $nginxd ] || exit 0
# Start nginx daemons functions.
start() {
    if [ -e $nginx_pid ];then
        echo "nginx already running...."
        exit 1
    fi
    echo -n $"Starting $prog: "
    daemon $nginxd -c ${nginx_config}
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && touch /var/lock/subsys/nginx
    return $RETVAL
}
# Stop nginx daemons functions.
stop() {
    echo -n $"Stopping $prog: "
    killproc $nginxd
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f /var/lock/subsys/nginx /usr/local/nginx/logs/nginx.pid
}

reload() {
    echo -n $"Reloading $prog: "
    #kill -HUP `cat ${nginx_pid}`
    killproc $nginxd -HUP
    RETVAL=$?
    echo
}
# See how we were called.
case "$1" in
    start)
    start
    ;;
    stop)
    stop
    ;;
    reload)
    reload
    ;;
    restart)
    stop
    start
    ;;
    status)
    status $prog
    RETVAL=$?
    ;;
    *)
    echo $"Usage: $prog {start|stop|restart|reload|status|help}"
    exit 1
esac
exit $RETVAL
"""
chmod 775 /etc/init.d/nginx
chkconfig nginx on
```

>######* 启动nginx######

````
service nginx start 或 /usr/local/nginx/sbin/nginx   #启动nginx
service nginx reload 或 /usr/local/nginx/sbin/nginx -s reload #重启nginx
servcie nginx stop 或 /usr/local/nginx/sbin/nginx -s stop #停止nginx
````

-
### 安装Mysql ###
---
>#####以Mysql 5.6.21 为例：#####
>######* 下载安装文件 ######

````
wget ftp://ftp.ntu.edu.tw/pub/MySQL/Downloads/MySQL-5.6/mysql-5.6.21.tar.gz
````
>######* 安装cmake 编译工具 ######
下载地址 https://cmake.org/files/

````
wget http://www.cmake.org/files/v2.8/cmake-2.8.5.tar.gz #以2.8.5为例
tar zxvf cmake-2.8.5.tar.gz
# 编译安装
cd cmake-2.8.5
./bootstrap
make && make install
cmake -version
````
>######* 创建用户和组 ######

````
groupadd mysql
useradd -g mysql  -s /usr/sbin/nologin  mysql
````
>######* 创建安装 && 数据库目录 ######

````
mkdir  /usr/local/mysql
mkdir  /usr/local/mysql/data 
````
>######* 解压并进入目录 ######

````
tar zxvf mysql-5.6.21.tar.gz
cd mysql-5.6.21
````
>######* 编译及安装mysql ######

````
# cmake编译:
cmake . \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
````
>######* 安装到目录 ######

````
make && make install
````
>######* 复制配置文件 ######

````
cp support-files/my-default.cnf  /etc/my.cnf 
````
>######* 设置权限 ######

````
chmod +x /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql/data
````
>######* 配置开机自启动 ######

````
cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
````
>######* 修改my.cnf配置 ######

````
vim /etc/my.cnf
"""
# [mysqld] 添加：
datadir=/usr/local/mysql/data
default-storage-engine=MyISAM
""" 
# 以下可选：
log-error =/usr/local/mysql/data/error.log
pid-file = /usr/local/mysql/data/mysql.pid
user = mysql
tmpdir = /tmp
````
>######* 初始化数据库 ######

````
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
````
>#####* 启动MySQL ######

````
/usr/local/mysql/bin/mysqld_safe  --defaults-file=/etc/my.cnf 
# 或者
/etc/init.d/mysqld start （service mysqld start）
# 如果出现无法找到/tmp/mysql.sock 
# 建立软链接
ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
# 如果出现Starting MySQL.The server quit without updating PID file (/[FAILED]l/mysql/data/mysql.pid).
# 在/etc/my.cnf 中添加一行 
vim /etc/my.cnf
innodb_buffer_pool_size=20M
````


