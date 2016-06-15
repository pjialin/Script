#!/bin/bash
echo ''
echo '===LNMP一键安装脚本==='
echo ''
install_dir='/tmp/lnmp' #定义安装目录
install_txt='/tmp/lnmp/lnmp_install.txt' #定义安装日志文件名

#创建安装目录
mkdir $install_dir
echo '创建安装目录成功...'
echo ''
cd $install_dir

#安装必备工具
echo '===正在安装必备工具...==='
echo ''
yum -y install make gcc gcc-c++ gcc-g77 flex bison file \
libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel \
libpng libpng-devel libpng10 libpng10-devel gd gd-devel \
freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel \
glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel \
ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel \
krb5 krb5-devel libidn libidn-devel openssl openssl-devel \
gettext gettext-devel ncurses-devel gmp-devel pspell-devel \
unzip libcap lsof lrzsz >> $install_txt 2>&1


#安装PHP
echo '===PHP安装==='
echo ''
#下载PHP
wget -q http://cn2.php.net/distributions/php-5.6.15.tar.gz
echo 'PHP文件下载完成...'
echo ''
tar zxvf php-5.6.15.tar.gz >> $install_txt 2>&1
cd php-5.6.15
#创建 www 用户
groupadd www
useradd -g www -s /sbin/nologin -M www
echo '正在安装...'
echo ''
#编译安装
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
--with-zlib \
--disable-fileinfo >> $install_txt 2>&1
#安装到目录
make >> $install_txt 2>&1
make install >> $install_txt 2>&1 #安装到目录
echo '正在配置PHP服务...'
echo ''
#拷贝php配置文件到安装目录
cp php.ini-development /usr/local/php/etc/php.ini
#添加php-fpm服务&&开启启动
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf  #拷贝默认php-fpm配置文件到配置目录
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm #拷贝安装目录下的启动文件到服务
chmod +x /etc/init.d/php-fpm
#启动php-fpm
#service php-fpm start
#添加PHP到环境变量
path_str='PATH=$PATH:/usr/local/php/bin\nPATH=$PATH:/usr/local/nginx/sbin\nexport PATH'
sed -i '$a '"$path_str" /etc/profile
source /etc/profile #使修改生效
echo 'PHP安装完成...'
echo ''
echo '===安装Nginx==='
echo ''
#安装Nginx #
#安装依赖包 zlib && pcre
#安装PCRE：
echo '安装必要扩展pcre...'
echo ''
cd $install_dir
wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
tar zxvf pcre-8.37.tar.gz >> $install_txt 2>&1
cd pcre-8.37
./configure --prefix=/usr/local/pcre >> $install_txt 2>&1
make >> $install_txt 2>&1
make install >> $install_txt 2>&1
echo 'Success...'
echo ''
#安装ZLIB：
echo '安装必要扩展zlib...'
echo ''
cd $install_dir
wget -q http://zlib.net/zlib-1.2.8.tar.gz
tar zxvf zlib-1.2.8.tar.gz >> $install_txt 2>&1
cd zlib-1.2.8
./configure --prefix=/usr/local/zlib >> $install_txt 2>&1
make >> $install_txt 2>&1
make install >> $install_txt 2>&1
echo 'Success...'
echo ''
#*载安装文件
cd $install_dir
wget -q http://nginx.org/download/nginx-1.8.0.tar.gz
echo 'Nginx下载完成...'
echo ''
tar zxvf nginx-1.8.0.tar.gz >> $install_txt 2>&1
cd nginx-1.8.0
#进行编译安装
./configure \
--prefix=/usr/local/nginx \
--with-zlib=/tmp/lnmp/zlib-1.2.8 \
--with-pcre=/tmp/lnmp/pcre-8.37 >> $install_txt 2>&1
#安装到目录
make >> $install_txt 2>&1
make install >> $install_txt 2>&1 #安装到目录
echo '配置Nginx...'
echo ''
#配置nginx支持php
mkdir /usr/local/nginx/conf/vhost  #创建Nginx虚拟机目录
mkdir /usr/local/nginx/conf/rewrite  #创建nginx rewrite重写目录
#vim /usr/local/nginx/conf/nginx.conf #编辑nginx配置文件
#将Server{}部分删除 增加一行
#"""
#include vhost/*.cnf;
#"""
rpt_file='/usr/local/nginx/conf/nginx.conf'
rpt_str='\    include vhost/*.conf;'
sed -i "35,79c ${rpt_str}" $rpt_file
#vim /usr/local/nginx/conf/vhost/default.conf #编辑虚拟主机
#"""
nginx_server_file='/usr/local/nginx/conf/vhost/default.conf'
nginx_server_conf='server {\n
    listen     80 default;  #监听80端口 && 设为默认主机\n
    server_name  _;           #绑定域名 _为全部\n
    root /home/WWW;           #网站目录\n
    #include rewrite/default.cnf #引入重写文件\n
    location ~ .*\.php$\n
    {\n
        fastcgi_pass  127.0.0.1:9000;\n
        fastcgi_index index.php;\n
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;\n
        include fastcgi.conf;\n
    }\n
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$\n
    {\n
        expires 30d;\n
    }\n
    location ~ .*\.(js|css)?$\n
    {\n
        expires 1h;\n
    }\n
    access_log  logs/default.access.log;  #nginx日志\n
}';
echo -e $nginx_server_conf > $nginx_server_file
#配置Nginx开机启动
nginx_start_conf='#!/bin/bash\n
# Startup script for the nginx Web Server\n
# chkconfig: - 85 15\n
# description: nginx is a World Wide Web server. It is used to serve\n
# HTML files and CGI.\n
# processname: nginx\n
# pidfile: /usr/local/nginx/logs/nginx.pid\n
# config: /usr/local/nginx/conf/nginx.conf\n
nginxd=/usr/local/nginx/sbin/nginx\n
nginx_config=/usr/local/nginx/conf/nginx.conf\n
nginx_pid=/usr/local/nginx/logs/nginx.pid\n
RETVAL=0\n
prog="nginx"\n
# Source function library.\n
.  /etc/rc.d/init.d/functions\n
# Source networking configuration.\n
.  /etc/sysconfig/network\n
# Check that networking is up.\n
[ ${NETWORKING} = "no" ] && exit 0\n
[ -x $nginxd ] || exit 0\n
# Start nginx daemons functions.\n
start() {\n
    if [ -e $nginx_pid ];then\n
        echo "nginx already running...."\n
        exit 1\n
    fi\n
    echo -n $"Starting $prog: "\n
    daemon $nginxd -c ${nginx_config}\n
    RETVAL=$?\n
    echo\n
    [ $RETVAL = 0 ] && touch /var/lock/subsys/nginx\n
    return $RETVAL\n
}\n
# Stop nginx daemons functions.\n
stop() {\n
    echo -n $"Stopping $prog: "\n
    killproc $nginxd\n
    RETVAL=$?\n
    echo\n
    [ $RETVAL = 0 ] && rm -f /var/lock/subsys/nginx /usr/local/nginx/logs/nginx.pid\n
}\n
\n
reload() {\n
    echo -n $"Reloading $prog: "\n
    #kill -HUP `cat ${nginx_pid}`\n
    killproc $nginxd -HUP\n
    RETVAL=$?\n
    echo\n
}\n
# See how we were called.\n
case "$1" in\n
    start)\n
    start\n
    ;;\n
    stop)\n
    stop\n
    ;;\n
    reload)\n
    reload\n
    ;;\n
    restart)\n
    stop\n
    start\n
    ;;\n
    status)\n
    status $prog\n
    RETVAL=$?\n
    ;;\n
    *)\n
    echo $"Usage: $prog {start|stop|restart|reload|status|help}"\n
    exit 1\n
esac\n
exit $RETVAL'
echo -e $nginx_start_conf > /etc/init.d/nginx
chmod 775 /etc/init.d/nginx
chkconfig nginx on
#"""
echo 'Nginx安装完成...'
echo ''
#启动nginx
#/usr/local/nginx/sbin/nginx   #启动nginx

#安装Mysql
echo '===安装Mysql==='
echo ''
cd $install_dir
#下载安装文件
wget -q ftp://ftp.ntu.edu.tw/pub/MySQL/Downloads/MySQL-5.6/mysql-5.6.21.tar.gz
echo 'Mysql下载完成...'
echo ''
#安装cmake 编译工具
echo 'Mysql安装工具cmake安装中...'
wget -q http://www.cmake.org/files/v2.8/cmake-2.8.5.tar.gz --no-check-certificate #以2.8.5为例
tar zxvf cmake-2.8.5.tar.gz >> $install_txt 2>&1
# 编译安装
cd cmake-2.8.5
./bootstrap >> $install_txt 2>&1
make >> $install_txt 2>&1
make install >> $install_txt 2>&1
cmake -version >> $install_txt 2>&1
echo 'Success...'
echo ''
#创建用户和组
groupadd mysql
useradd -g mysql  -s /usr/sbin/nologin  mysql
#创建安装 && 数据库目录
mkdir  /usr/local/mysql
mkdir  /usr/local/mysql/data
#解压并进入目录
cd $install_dir
tar zxvf mysql-5.6.21.tar.gz >> $install_txt 2>&1
cd mysql-5.6.21
#编译及安装mysql
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
-DDEFAULT_COLLATION=utf8_general_ci >> $install_txt 2>&1
#安装到目录
make >> $install_txt 2>&1
make install >> $install_txt 2>&1
echo '正在进行Mysql配置服务...'
#复制配置文件
cp support-files/my-default.cnf  /etc/my.cnf
#设置权限
chmod +x /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql/data
#配置开机自启动
cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
#修改my.cnf配置
#vim /etc/my.cnf
#"""
mysql_conf="[mysqld]\n
datadir=/usr/local/mysql/data\n
default-storage-engine=MyISAM\n
log-error =/usr/local/mysql/data/error.log\n
pid-file = /usr/local/mysql/data/mysql.pid\n
user = mysql\n
tmpdir = /tmp\n
"
echo -e $mysql_conf > /etc/my.cnf
#"""
#初始化数据库
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data >> $install_txt 2>&1


echo '===安装完成==='
echo ''

#启动PHP
echo '启动PHP...'
echo ''
phpfpm_start_info=`service php-fpm start`
if echo $phpfpm_start_info | grep -q 'done'
then
    echo 'Start PHP Success...'
else
    echo 'Start PHP Fail...'
fi
echo ''
#启动Nginx
echo '启动Nginx...'
echo ''
nginx_start_info=`service nginx start`
if echo $nginx_start_info | grep -q 'OK'
then
    echo 'Nginx Start Success...'
else
    echo 'Nginx Start Fail...'
fi
echo ''
#启动MySQL
echo '启动Mysql...'
mysql_start_info=`service mysqld start`
need_start_mysql=0
# 如果出现无法找到/tmp/mysql.sock
# 建立软链接
if echo $mysql_start_info | grep -q 'mysql.sock'
then
    ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
    need_start_mysql=1
elif echo $mysql_start_info | grep -q 'mysql.pid'
then
# 如果出现Starting MySQL.The server quit without updating PID file (/[FAILED]l/mysql/data/mysql.pid).
# 在/etc/my.cnf 中添加一行
#vim /etc/my.cnf
#innodb_buffer_pool_size=20M
    sed -i '$a innodb_buffer_pool_size=20M' /etc/my.cnf
    need_start_mysql=1
elif echo $mysql_start_info | grep -q 'OK'
then
    echo 'Start Mysql Success ...'
    echo ''
else
    echo 'Start Mysql Fail ...'
    echo ''
fi
#重新启动mysql
if [ $need_start_mysql -gt 0 ];then
    mysql_start_info=`service mysqld start`
    if echo $mysql_start_info | grep -q 'OK'
    then
        echo 'Start Mysql Success ...'
        echo ''
    else
        echo 'Start Mysql Fail ...'
        echo ''
    fi
fi
