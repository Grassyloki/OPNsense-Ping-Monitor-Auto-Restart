#!/bin/sh

# =============================================================================
# Ping Monitor Script for OPNsense
# Tests connectivity and executes command on failure
# =============================================================================

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================

# HOST: The IP address or hostname to ping for connectivity testing
# Example: "8.8.8.8" (Google DNS), "1.1.1.1" (Cloudflare), "192.168.1.1" (local gateway)
HOST="8.8.8.8"

# MAX_ATTEMPTS: Number of consecutive ping failures before executing the failure command
# Example: 4 (will ping 4 times before taking action)
MAX_ATTEMPTS=4

# PING_TIMEOUT: How long to wait for each ping response (in seconds)
# Example: 3 (wait 3 seconds for each ping reply)
PING_TIMEOUT=3

# SLEEP_BETWEEN_ATTEMPTS: Delay between failed ping attempts (in seconds)
# Example: 1 (wait 1 second between retries)
SLEEP_BETWEEN_ATTEMPTS=1

# COMMAND_ON_FAILURE: Command to execute when all ping attempts fail
# Example: "pluginctl -s wireguard restart" (restart WireGuard service)
# Example: "reboot" (reboot the system)
# Example: "/usr/local/etc/rc.d/wireguard restart" (restart WireGuard daemon)
COMMAND_ON_FAILURE="reboot"

# VERBOSE: Enable/disable detailed logging output
# Example: 1 (enabled - show all messages), 0 (disabled - quiet mode)
VERBOSE=1

# Color definitions
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[0;37m'
PURPLE='\033[0;35m'
RESET='\033[0m'

# =============================================================================
# SCRIPT INITIALIZATION
# =============================================================================

# Print configuration in purple
printf "${PURPLE}========================================${RESET}\n"
printf "${PURPLE}Configuration Variables:${RESET}\n"
printf "${PURPLE}  HOST: ${HOST}${RESET}\n"
printf "${PURPLE}  MAX_ATTEMPTS: ${MAX_ATTEMPTS}${RESET}\n"
printf "${PURPLE}  PING_TIMEOUT: ${PING_TIMEOUT}${RESET}\n"
printf "${PURPLE}  SLEEP_BETWEEN_ATTEMPTS: ${SLEEP_BETWEEN_ATTEMPTS}${RESET}\n"
printf "${PURPLE}  COMMAND_ON_FAILURE: ${COMMAND_ON_FAILURE}${RESET}\n"
printf "${PURPLE}  VERBOSE: ${VERBOSE}${RESET}\n"
printf "${PURPLE}========================================${RESET}\n"
printf "\n"

# Initialize attempt counter
attempt=1

# =============================================================================
# FUNCTIONS
# =============================================================================

log_message() {
    color=$1
    message=$2
    if [ "$VERBOSE" -eq 1 ]; then
        printf "${color}$(date '+%Y-%m-%d %H:%M:%S') - ${message}${RESET}\n"
    fi
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

log_message "$CYAN" "Starting ping monitor for host: $HOST"
log_message "$CYAN" "Will attempt $MAX_ATTEMPTS times with $SLEEP_BETWEEN_ATTEMPTS second intervals"

while [ $attempt -le $MAX_ATTEMPTS ]; do
    log_message "$CYAN" "Attempt $attempt/$MAX_ATTEMPTS: Pinging $HOST..."
    
    # FreeBSD ping syntax: -c count -W timeout_ms
    if ping -c 1 -W $(expr $PING_TIMEOUT \* 1000) "$HOST" > /dev/null 2>&1; then
        log_message "$GREEN" "SUCCESS: Host $HOST is reachable"
        exit 0
    else
        log_message "$RED" "FAILED: Host $HOST is not reachable (attempt $attempt)"
        
        if [ $attempt -lt $MAX_ATTEMPTS ]; then
            log_message "$YELLOW" "Waiting $SLEEP_BETWEEN_ATTEMPTS seconds before next attempt..."
            sleep $SLEEP_BETWEEN_ATTEMPTS
        fi
    fi
    
    attempt=$(expr $attempt + 1)
done

# All ping attempts failed
log_message "$RED" "ERROR: Host $HOST failed to respond after $MAX_ATTEMPTS attempts"
log_message "$YELLOW" "Executing failure command: $COMMAND_ON_FAILURE"

# Execute the failure command
eval "$COMMAND_ON_FAILURE"

exit 1
