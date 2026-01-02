# 8-Bit Arithmetic Logic Unit

This repository contains a **CPU-style 8-bit execution unit** implemented in **Verilog HDL**, featuring a single-cycle ALU and multi-cycle signed multiplication and division using **FSM-controlled datapaths**.

The primary focus of this project is **FSM design, control logic, and verification**, rather than just arithmetic functionality.

---

## Key Highlights

- 8-bit ALU (ADD, SUB, AND, OR, XOR, NOT)
- Signed multiplication using shift-add FSM
- Signed restoring division using FSM
- Opcode-based execution unit top
- Clean start / busy / done handshake
- Quartus-compatible 
- Fully simulated and verified

---

## Project Structure

- Base_Code/
- Screenshots/
- ├── RTL view/
- ├── Simulations/
- └── State Diagram/
- Testbenches/
- README.md


### Folder Description

- **Base_Code/**  
  Contains Verilog RTL files for:
  - ALU
  - Signed multiplier
  - Signed divider
  - Execution unit top module

- **Testbenches/**  
  Contains unit-level and system-level testbenches used for verification

- **Screenshots/RTL view/**  
  RTL schematics generated using Quartus

- **Screenshots/Simulations/**  
  Simulation waveforms captured from ModelSim

- **Screenshots/State Diagram/**  
  FSM state diagrams for control logic

---

## Supported Operations

### ALU (Single-Cycle)

| Opcode | Operation |
|------|----------|
| 0000 | ADD |
| 0001 | SUB |
| 0010 | AND |
| 0011 | OR |
| 0100 | XOR |
| 0101 | NOT |

### Multi-Cycle Operations

| Opcode | Operation |
|------|----------|
| 1000 | Signed Multiplication |
| 1001 | Signed Division |

---

## Execution Protocol

Each instruction follows a CPU-style handshake:

- `start` : 1-cycle pulse to begin execution  
- `busy`  : High while operation is in progress  
- `done`  : 1-cycle pulse when result is valid  

Only **one execution unit is active at a time**.

---

## Verification

Verification was performed using **hierarchical testbenches**:

- ALU functional testbench
- Multiplier FSM testbench
- Divider FSM testbench
- Execution unit top-level testbench

Simulation waveforms confirm:
- Correct FSM sequencing
- No deadlocks or infinite loops
- Correct result visibility at `done`

---

## Tools Used

- Verilog HDL (IEEE-1364 )
- Quartus Prime Lite (Synthesis and RTL view)
- ModelSim / QuestaSim (Simulation)

---

## Notes

- All control logic is implemented using **Moore FSMs**
- Multi-cycle arithmetic improves hardware efficiency
- Design is modular and easily extensible

---

## Status

- Design complete
- Synthesized successfully
- Simulated and verified

