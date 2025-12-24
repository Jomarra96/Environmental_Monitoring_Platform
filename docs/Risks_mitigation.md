## Risks & Mitigation

| Risk                         | Likelihood | Impact   | Mitigation                                                   |
| ---------------------------- | ---------- | -------- | ------------------------------------------------------------ |
| **WiFi module unavailable**  | Medium     | High     | Use mocked AT command responses; document interface for future hardware swap |
| **100ms deadline missed**    | Low        | High     | Profile early with timers; simplify processing if needed;    |
| **Memory overflow**          | Medium     | High     | Compile-time checks via linker; size analysis in CI; minimal 2-item raw buffer (in Data_flow.png) |
| **TLS handshake complexity** | Medium     | Medium   | Use WiFi module's built-in TLS; fall back to pre-shared keys |
| **Heap allocation slip**     | Low        | Critical | Wrap malloc/free with linker errors; compile with -fno-builtin-malloc |
| **Power budget exceeded**    | Medium     | High     | Measure early; STM32U5 Stop2 mode; reduce transmission frequency if needed |
| **Network outage > 1 week**  | Low        | Medium   | CBOR queue sized for 7 days; delta encoding for overflow scenarios |

Possible Bottlenecks:

1.  **WiFi Module Selection**: Blocks Milestones 3, 4, 8. Decision needed on ESP32 vs nRF70. Already decided ESP32 for simplicity.
2.  **TLS Certificate Storage**: 256KB Flash is tight. Consider using WiFi module's certificate storage or minimal root CA.
3.  **Testing Without Hardware**: OpenOCD debugging (#30) blocks efficient development. Prioritize simulator/mock infrastructure.
