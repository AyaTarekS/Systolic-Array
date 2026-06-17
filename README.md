# Systolic Array Matrix Multiplier (SystemVerilog)

A parameterized N×N **systolic array** for computing matrix multiplication `C = A × B` in hardware, written in SystemVerilog. Operands are streamed into the array via skewed (diagonal) injection, multiplied and accumulated in place by an array of processing units, and the result matrix is read out in parallel.

## Overview

A systolic array computes matrix products by passing partial sums between a grid of identical processing elements every clock cycle, rather than routing all data through a central ALU. Each processing unit (PU) in the grid receives one element of `A` from its west neighbor and one element of `B` from its north neighbor, multiplies them, adds the product to a running accumulator, and forwards `A` eastward and `B` southward to the next PU. After enough cycles for data to propagate across the array, every PU holds one final element of `C`.

This project implements that architecture generically for any array size `N` and operand width `WIDTH`, along with a self-checking testbench that drives a known `A` and `B` matrix and prints the resulting `C` matrix cycle by cycle.

## File Structure

| File | Module | Description |
|---|---|---|
| `interface.sv` | `sys_arr_if` | SystemVerilog interface bundling the array's `clk`, `reset`, and the `a`, `b`, `c` matrices, with a clocking block and `DUT`/`TEST`/`MON` modports for clean separation between the design, testbench, and any monitor. |
| `processunit.sv` | `PU` | A single processing element: registers its `a_in`/`b_in` inputs, accumulates `a*b` into `acc`, and forwards the registered operands to its neighbors. |
| `sysArr.sv` | `sysArr` | The top-level N×N array. Instantiates an `N×N` grid of `PU`s, generates the skewed diagonal injection schedule for `A` and `B`, and wires PU outputs into the shared `c` matrix. |
| `test.sv` | `sysArr_tb` | Testbench module. Drives `A` and `B` test matrices into the interface, releases reset, and prints the evolving `C` matrix every cycle until the pipeline has fully drained. |
| `top.sv` | `top` | Simulation top: generates the clock, instantiates the interface, connects the DUT (`sysArr`) and testbench (`sysArr_tb`) to it. |
| `counter.sv` | `counter` | Standalone parameterized free-running counter with synchronous reset and wraparound at `2^WIDTH - 1`. Not currently instantiated anywhere in the array datapath — included as a reusable utility/building block. |
| `package.sv` | — | Empty placeholder, reserved for shared typedefs/parameters if the project grows (e.g. centralizing `WIDTH`/`N`/`out_WIDTH` definitions). |

## Architecture

```
        B matrix (streamed in from the top, skewed)
              │       │
              ▼       ▼
        ┌─────────┬─────────┐
A ──►   │  PU(0,0)│  PU(0,1)│  ──► (a_out unused at edge)
        ├─────────┼─────────┤
A ──►   │  PU(1,0)│  PU(1,1)│
        └─────────┴─────────┘
              │       │
              ▼       ▼
        (b_out unused at edge)
```

* **Grid:** `N × N` instances of `PU`, generated with nested `generate` loops in `sysArr`.
* **Data flow:** `A` flows left-to-right (row-wise), `B` flows top-to-bottom (column-wise). Each `PU` registers its inputs and forwards them one step further into the grid on every clock edge — this is what makes it "systolic."
* **Skewed injection:** Row `i` of `A` and column `j` of `B` are not injected simultaneously; each is delayed by its row/column index (`inj_count >= i && inj_count < i + N`, etc.) so that the correct operand pairs arrive at each `PU` in lockstep as they propagate diagonally through the array.
* **Accumulation:** Each `PU` keeps a running accumulator `acc`, sized `out_WIDTH = 2*WIDTH + clog2(N)` bits to avoid overflow across `N` multiply-accumulate steps.
* **Output:** `c_bus[row][col]`, written by each `PU`'s `acc_out`, is continuously assigned to the interface's `c` matrix — `c[row][col]` converges to the correct dot-product result for `C = A × B` once the injected data has fully propagated.

### Parameters

| Parameter | Meaning | Default |
|---|---|---|
| `N` | Array dimension (matrices are `N × N`) | 2 |
| `WIDTH` | Bit width of each `A`/`B` element | 8 |
| `out_WIDTH` | Bit width of each `C` element / accumulator | `2*WIDTH + clog2(N)` |

All parameters are propagated consistently from `top` down through `sysArr_if`, `sysArr`, and `PU`.


## Running the Simulation

Any SystemVerilog-capable simulator (e.g. Synopsys VCS, Cadence Xcelium, Mentor/Siemens QuestaSim, or the open-source Verilator) can compile and run this project. Example with QuestaSim/ModelSim:

```bash
vlog interface.sv package.sv processunit.sv sysArr.sv test.sv top.sv
vsim -c top -do "run -all; quit"
```

Compile order matters: the interface (`interface.sv`) must be compiled before any module that uses it (`sysArr.sv`, `test.sv`, `top.sv`).

## Notes & Possible Extensions

- `counter.sv` and `package.sv` are currently scaffolding rather than active parts of the datapath — useful starting points if the project is extended (e.g. a counter-driven control/sequencing FSM, or a shared package for common parameter and type definitions).
- The accumulators in each `PU` never reset mid-run except on global `rst_n`, so re-running a new matrix multiplication requires a full reset pulse.
- The current testbench is directed (fixed input matrices); a natural next step would be randomized stimulus with a self-checking scoreboard that computes the expected product in SystemVerilog/software and compares it against `arrif.c`.
