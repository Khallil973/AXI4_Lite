# AXI4-Lite

This repository contains hardware designs implementing the **AXI4-Lite** bus protocol. AXI4-Lite is a simplified version of AXI4, designed for peripherals requiring a lightweight communication interface with reduced complexity.

## AXI4-Lite Bus Protocol

AXI4-Lite is a subset of the **AXI4 protocol**, specifically designed for **low-resource, low-complexity** applications. Unlike AXI4, which supports **burst transactions** and **out-of-order execution**, AXI4-Lite follows a **simple request-response** model, making it ideal for control registers and basic data transfers.

### Key Features

- **Single Transaction per Request** – No burst transactions, ensuring a one-to-one request-response mechanism.
- **Simple Addressing** – Uses a single address phase for each read or write operation.
- **Separate Read and Write Channels** – Independent channels for streamlined communication.
- **Valid-Ready Handshaking** – Synchronizes data transfers between master and slave devices.
- **Low Resource Utilization** – Optimized for FPGAs and resource-constrained SoCs.

## Handshaking Communication Principle

Handshaking in AXI4-Lite ensures proper data synchronization between master and slave devices. The protocol uses **valid** and **ready** signals to establish successful data transfers:

- The **master asserts `valid`** when data is available for transmission.
- The **slave asserts `ready`** when it is prepared to accept data.
- A successful transaction occurs **only when both `valid` and `ready` are high** at the same time.

This mechanism prevents data loss and ensures reliable communication.

## Applications of AXI4-Lite

AXI4-Lite is commonly used in:

- **Control and Status Registers** – Ideal for simple register-based interfaces in peripheral devices.
- **Low-Speed Communication Interfaces** – Used for peripherals that do not require high-speed data throughput.
- **Memory-Mapped IO** – Frequently used for accessing memory-mapped devices in SoCs.

## References

- [AMBA AXI and ACE Protocol Specification](https://www.realdigital.org/doc/a9fee931f7a172423e1ba73f66ca4081)
- [AXI4 Specification (PDF)](http://www.gstitt.ece.ufl.edu/courses/fall15/eel4720_5721/labs/refs/AXI4_specification.pdf)
