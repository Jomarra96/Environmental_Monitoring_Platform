# Sensor Data Acquisition:
## Interface with 2 sensor types (e.g., temperature, humidity), simulate if hardware unavailable
## Handle interrupts or polling based on sensor characteristics, include data validation
## Implement sensor failure detection and recovery

# Data Processing Pipeline:
## Filter and validate sensor readings
## Detect anomalous conditions
## Prepare data for transmission

# Communication Interface:
## Implement secure data transmission protocol
## No token refresh or expiry handling required
## Payload: CBOR- serialized (use tinycbor)
## Handle network disconnects:
## Buffer data during network outages
## Retry with exponential backoff
## Do not reboot or crash on failure

# System Management:
## Monitor system health and power status
## Ensure deterministic real-time behavior

# Requirements:
## Zero heap allocation (all memory statically allocated)
## Real- time performance (process and transmit data within specified timeframes)
## Error resilience (no crashes, graceful recovery from failures)
## Code quality (clean, maintainable, well- documented)
