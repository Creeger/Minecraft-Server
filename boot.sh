#!/bin/sh

echo "Starting Minecraft server..."

sh /server/startserver.sh &
SERVER_PID=$!

echo "Server PID: $SERVER_PID"

# EULA
echo "eula=true" > /server/eula.txt
echo "EULA set"

# Wait for server.properties
while [ ! -f /server/server.properties ]; do
    sleep 2
done

echo "server.properties detected"

# Add server RAM usage for the user to adjust
while true; do
    sed -i 's/^enable-rcon=.*/enable-rcon=true/' /server/server.properties
    sed -i 's/^rcon.port=.*/rcon.port=25575/' /server/server.properties
    sed -i "s/^rcon.password=.*/rcon.password=${RCON_PASSWORD}/" /server/server.properties
    sed -i "s/^allow-flight=.*/allow-flight=${ALLOW_FLIGHT}/" /server/server.properties
    sed -i "s/^difficulty=.*/difficulty=${DIFFICULTY}/" /server/server.properties

    sed -i "s/^-Xmx.*/-Xmx${SERVER_RAM}/" /server/user_jvm_args.txt

    if grep -q "enable-rcon=true" /server/server.properties; then
        break
    fi
    sleep 2
done

echo "RCON enabled"
echo "RCON variables set"
echo "Allow flight set to ${ALLOW_FLIGHT}"
echo "Difficulty set to ${DIFFICULTY}"
echo "Server RAM set to ${SERVER_RAM}"

wait $SERVER_PID