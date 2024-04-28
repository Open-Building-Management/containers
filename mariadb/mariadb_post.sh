#!/command/with-contenv sh

# post commands = commands to execute after service is successfully launched

while ! mysql -e "" 2> /dev/null; do
    sleep 1
done
echo "mariadb has started :-)"
