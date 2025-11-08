# OPNsense Ping Monitor & Auto-Restart

A monitoring script for OPNsense that tests network connectivity and automatically restarts services or reboots on failure. Useful for WireGuard tunnels, VPN connections, or any service that needs automatic recovery.

## Features

- Monitors connectivity to a specified host via ping
- Configurable retry attempts and timeouts
- Color-coded console output for easy log reading
- Executes custom commands on failure (restart services, reboot, etc.)
- Integrates with OPNsense cron system

## Installation

### 1. Copy the script
```bash
# Copy to /root directory
curl -o /root/ping_test_restart_wg.sh https://raw.githubusercontent.com/Grassyloki/OPNsense-Ping-Monitor-Auto-Restart/main/ping_test_restart_wg.sh
chmod +x /root/ping_test_restart_wg.sh
```

### 2. Create configd action
Create `/usr/local/opnsense/service/conf/actions.d/actions_pingtest.conf`:
```ini
[restart]
command:/root/ping_test_restart_wg.sh
parameters:
type:script
message:Running WireGuard ping test restart
description:WireGuard Ping Test and Restart
```

### 3. Register the action
```bash
service configd restart
```

### 4. Test manually
```bash
configctl pingtest restart
```

### 5. Add cron job via GUI
- Go to **System → Settings → Cron**
- Click **Add**
- Select "WireGuard Ping Test and Restart" from the **Command** dropdown
- Set your schedule (e.g., `*/5` minutes for every 5 minutes)
- Ensure **Who** is set to `root`
- Click **Save**

## Configuration

Edit the variables at the top of the script:

```bash
HOST="8.8.8.8"                          # Host to ping
MAX_ATTEMPTS=4                          # Number of failures before action
PING_TIMEOUT=3                          # Timeout per ping (seconds)
SLEEP_BETWEEN_ATTEMPTS=1                # Delay between retries (seconds)
COMMAND_ON_FAILURE="reboot"             # Command to execute on failure
VERBOSE=1                               # Enable (1) or disable (0) logging
```

### Common Commands

```bash
# Restart WireGuard plugin
COMMAND_ON_FAILURE="pluginctl -s wireguard restart"

# Restart WireGuard daemon
COMMAND_ON_FAILURE="/usr/local/etc/rc.d/wireguard restart"

# Reboot system
COMMAND_ON_FAILURE="reboot"

# Restart OpenVPN
COMMAND_ON_FAILURE="/usr/local/etc/rc.d/openvpn restart"
```

## Use Cases

- **WireGuard monitoring**: Restart WireGuard when tunnel connectivity fails
- **VPN failover**: Reboot or restart VPN when connection drops
- **ISP monitoring**: Track ISP connectivity and take action on outages
- **Service health checks**: Ensure critical services remain accessible

## Color Output

- **Cyan**: Informational messages
- **Yellow**: Warnings (waiting, retrying)
- **Green**: Success (host reachable)
- **Red**: Failures and errors
- **Purple**: Configuration display

## Requirements

- OPNsense firewall
- Root access
- FreeBSD-compatible shell environment

## License

MIT

## Contributing

Pull requests welcome. Keep it simple and functional.
