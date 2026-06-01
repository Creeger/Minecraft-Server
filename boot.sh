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

# Apply config (FIXED PATH + safer loop)
while true; do
    sed -i 's/^enable-rcon=.*/enable-rcon=true/' /server/server.properties
    sed -i 's/^rcon.port=.*/rcon.port=25575/' /server/server.properties
    sed -i "s/^rcon.password=.*/rcon.password=${RCON_PASSWORD}/" /server/server.properties
    sed -i "s/^allow-flight=.*/allow-flight=${ALLOW_FLIGHT}/" /server/server.properties
    sed -i "s/^difficulty=.*/difficulty=${DIFFICULTY}/" /server/server.properties

    if grep -q "enable-rcon=true" /server/server.properties; then
        break
    fi
    sleep 2
done

echo "RCON enabled"
echo "RCON variables set"
echo "Allow flight set to ${ALLOW_FLIGHT}"
echo "Difficulty set to ${DIFFICULTY}"

wait $SERVER_PID