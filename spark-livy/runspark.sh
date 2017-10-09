$SPARK_HOME/sbin/start-master.sh

if [ -z ${HOST+x} ]; then
  export LIBPROCESS_IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)
else
  export LIBPROCESS_IP=$HOST
fi

$LIVY_HOME/bin/livy-server $@