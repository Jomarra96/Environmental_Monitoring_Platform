# Hardware
## MCU: Any 32- bit microcontroller with RTOS support
## Sensors: Digital I2C sensors, analog ADC sensors

# Memory Management:
## Memory: ≤ 64KB RAM, ≤256KB Flash
## No dynamic allocation (malloc, new, calloc, realloc prohibited)
## Static memory analysis must show all memory usage at compile- time
## Buffer overflow protection required

# Real- Time Requirements:
## Sensor sampling: Sample sensors at a rate that matches their physical response time and application needs. Justify your sampling strategy based on sensor characteristics, power constraints, and data utility.
## Data processing: Complete within 100ms of sensor reading
## Error recovery: System must recover from failures within 30 seconds

# Power Constraints:
## Source: Continuous external power (Optional: Battery- powered)
## Power Strategy: Sleep depth, wake- up latency, transmission frequency, and radio selection.
## Battery lifetime (Optional): Average current over time must be low enough to enable 6+ months of operation on a single Li- ion cell
## Low battery (Optional): Graceful degradation when battery <20%

# Reliability Requirements:
## Uptime: >99.5% operational time

# Data loss: <0.1% of readings lost due to system failures
## Error recovery: No human intervention required for common failures

# Allowed Technologies:
## Languages: C or C++ (C++17 preferred)
## RTOS: FreeRTOS, Zephyr, or bare- metal with state machines
## Communication: TCP/UDP, MQTT, HTTP, gRPC over HTTP/2, or WebSocket
## Network: WIFI
## Serialization: Use CBOR for payload
## Security: TLS/SSL, authentication as needed
## Build System: Any (CMake, Make, platform-specific)
## Receiver Server: Provide reference server to validate transmission

# Hardware Abstraction:
## All hardware access must be abstracted via HAL (Hardware Abstraction Layer)
## Code should be portable across different 32- bit MCU platforms
## Sensors can be simulated for testing purposes

# Documentation Standards:
## Code comments: Explain complex logic and design decisions
## API documentation: Clear function and structure definitions
## Build instructions: Complete build and run procedures
## Testing methodology: How to verify functionality

# Implementation
## Compile without errors or warnings
## Execute with zero heap allocation (verify with memory analysis tools)
## Meet real-time constraints (demonstrate with timing measurements)
## Handle error scenarios gracefully (test with simulated failures)
## Demonstrate power-aware design (show sleep/wake cycles)
## Maintain data integrity (no corruption or loss during failures)
## Server logs (received data in JSON format for manual inspection)

# Build & Test:
## (Automated) build that works on Linux/macOS
## Memory usage report showing static allocation
## Performance measurements demonstrating real- time compliance
## Test scenarios Unit + integration tests, error scenario coverage