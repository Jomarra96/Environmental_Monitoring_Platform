# System design and decisions

## Hardware
Must have ADC and I2C ports.
Memory constrains are mostly irrelevant for this exercise, since we can log the memory usage and ensure it doesn't surpass the established limits. Given my current hardware availability, I will steer towards an STM32 U575, and provide viable solutions about WiFi within it. This will also allow us to plan for low power modes, where the U5 excels.

WiFi will limit our device selection. Going mainstream, we have the ESP32 (ESP8266 is long been not recommended for new designs) and nRF70 series families. 
For the WiFi and sensor systems, I will mock their implementation. I do not currently have the available hardware at hand not the time to order them.
To separate concerns and simplify the software, I will use a dual-mcu approach: a master (STM32U5) that controls the main logic and a slave (ESP32) that will only handle WiFi communication.
Diagram at ./docs/System_architecture.png

## Task Management Strategy: Choose between RTOS- based or state- machine approach. Explain your reasoning based on real- time requirements and power constraints.
There are a couple options here. We could integrate everything on-chip, which would require an RTOS (based on the tight WiFi timing requirements, plus most RTOS provide tested WiFi libraries and examples), or we can use a dual mcu approach.
The latter will be simpler and faster to implement, thanks to the clear separation of concerns between mcus, albeit more expensive for mass production (will start to matter in the 100s of thousands of devices). We can achieve the rest of requirements via a superloop with state machine while using an external, pre-flashed WiFi module (ESP32 or nRF70 are good options) to which you communicate using AT commands.

The sleep mode power draw (in the 10s of uA) pales in comparison to the active power needed (mA or 100s of mA for radio operation). Regarding our current real-time requirements (100ms for data processing latency), they are not too dependant on the task management strategy. The overhead of an RTOS is orders of magnitude smaller, assuming a systick of around 1ms.

To summarize, I will opt for a simpler state-machine approach with dual master-slave mcus. This choice will simplify design and implementation, reducing development time and clearly separating concerns within our system. This state-machine approach consists on:
- Single execution thread runs continuously in `main()`
- State machine provides cooperative multitasking
- Event flags (set by interrupts) trigger state transitions
- Non-blocking operations ensure responsive execution
Diagram at ./docs/Task_management.png

### Timing budget (really conservative, 100ms is a huge stretch)
TIME 0: Raw sensor data received by MCU (4 bytes: temp + humidity)
[0-5ms]     Filter & Validate
            ├─ Moving average update
            ├─ Range validation
            └─ Data quality scoring

[5-10ms]    Anomaly Detection  
            ├─ Threshold checks
            ├─ Rate-of-change analysis
            └─ Statistical outlier detection

[10-20ms]   Prepare for Transmission*
            ├─ CBOR encoding
            ├─ Buffer management
            └─ Add metadata

*It is more efficient to encode a bunch of data points at once that doing them one by one. Therefore, the preparation for transmission will NOT occur every time we receive data, but when we are ready to send something.

## Data Flow Design: How data flows from Sensor → Processing → Transmission. Include buffering, data persistence (if any), and overflow handling.
Data from the sensor will come in raw format to the uC, where it will be processed immediately. The processed data will be stored in a buffer and serialized once 1h of data is gathered. Once serialized in CBOR encoding, I estimate a week's worth of data will suffice for any WiFi issues the system may encounter (mainly connection not available due to external factors).
In case WiFi connection is not available for more than a week, old data will remain, and new data will be discarded.

### Memory budget (64kB)
Serialized data buffering will take around 20kB of space. The program itself will account for aprox 10-15kB, if using a state machine. That leaves us with half the memory available to account for stack overgrow, recursion, or else. This only accounts for one sensor type, however, so either increasing the number of sensors or the sampling rate would quickly make the serialized buffer grow, having to rethink the memory strategy.

## Power Management Approach: Sleep/wake cycles, radio duty cycling, low-battery behavior (if applicable).
### Power budget

## Error Handling Strategy: Sensor failure, network drop, TLS handshake failure—how does the system recover?

## Memory Management: How do you ensure zero heap usage while handling variable data rates and buffering?