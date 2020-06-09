#!/bin/sh

#chkconfig:2345 85 14
#description:spring-boot
#author litong
# 启动spring-boot项目

##################################
# define variable stop
##################################
APP_NAME=
CONFIG_FILE=$APP_HOME/application.properties
JAVA_HOME=/usr/java/jdk1.8.0_121/

##################################
# define variable stop
##################################

PRG="$0"
while [ -h "$0" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
APP_HOME=`dirname "$PRG"`


PID_FILE=$APP_HOME/$APP_NAME.pid
JAVA=$JAVA_HOME/bin/java
JAVA_OPTS="-jar"
RETVAL=0

################################
# define function start
################################

. /etc/init.d/functions

createLockFile(){
	lock_dir=/var/lock/subsys
	lock_file_path=$lock_dir/$APP_NAME
	if [ -w $lock_dir ]
	then
		touch $lock_file_path
	fi
}

start(){
	if [ -f $PID_FILE ]
	then 
		echo "$PID_FILE file exists, process already running,the pid file is $(cat $PID_FILE)"
	else
		createLockFile
		nohup $JAVA $JAVA_OPTS *.jar -Dspring.config.location=$CONFIG_FILE &
		# $! 获取最后一个进程的id,先执行nohup命令,在执行 java命令,获取到的是java命令的pid
		RETVAL=$!
		echo $RETVAL >> $PID_FILE
		echo "server start OK,the PID = $RETVAL"
	fi	
}

stop(){
	if [ -f $PID_FILE ]
	then
		killproc -p $PID_FILE
		rm -rf $PID_FILE
	else
		echo "$PID_FILE is not exists,process is not running"
	fi
}
################################
# define function stop
################################


##################################
# do action start
##################################
ACTION=$1
case $ACTION in
	start)
		start
	;;
	stop)
		stop
	;;
	restart)
		stop
		start
	;;
	*)
		echo "usage {start|stop|restart}"
	;;
esac