# Advent of FPGA 2025 - Day 3: Battery Joltage Calculator

**Hardcaml Solution for Jane Street's Advent of FPGA Challenge**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Problem Summary

Given battery banks (lines of digits 1-9), calculate maximum joltage by selecting specific batteries.

### Part 1: Two Batteries
Select exactly 2 batteries per bank to maximize the 2-digit joltage.

**Example:**
```
987654321111111 → 98 jolts (positions 0,1: digits 9,8)
811111111111119 → 89 jolts (positions 0,14: digits 8,9)  
234234234234278 → 78 jolts (positions 12,13: digits 7,8)
818181911112111 → 92 jolts (positions 6,11: digits 9,2)
Total: 357
```

### Part 2: Twelve Batteries
Select exactly 12 batteries per bank to maximize the 12-digit joltage.

**Example:**
```
987654321111111 → 987654321111 (skip three 1s at end)
811111111111119 → 811111111119 (skip three 1s)
234234234234278 → 434234234278 (skip 2,3,2 at start)
818181911112111 → 888911112111 (skip 1s near front)
Total: 3121910778619
```

## Solution Architecture

### Part 1: Hardware Solution (Hardcaml)

**Streaming architecture** that processes digits one at a time:
```
┌─────────────┐
│ Digit Input │
└──────┬──────┘
       │
   ┌───▼────┐
   │ Buffer │  (120 digits)
   │ (FIFO) │
   └───┬────┘
       │
   ┌───▼────────┐
   │ Pair Check │  (compare all pairs)
   │  Hardware  │
   └───┬────────┘
       │
   ┌───▼─────┐
   │   Max   │
   │ Tracker │
   └───┬─────┘
       │
   ┌───▼────────┐
   │ Accumulator│
   └────────────┘
```

**Key Features:**
- ✅ Fully synthesizable RTL
- ✅ ~500 LUTs estimated (Xilinx 7-series)
- ✅ No block RAM required
- ✅ 1 digit per clock cycle throughput
- ✅ Handles lines up to 120 digits
- ✅ 200+ MHz achievable on modern FPGAs

**Hardware Resources:**
- 120×4-bit digit buffer (shift register)
- 8-bit counter
- 7-bit max tracker  
- 32-bit accumulator
- Combinational comparison tree

**Algorithm:** For each incoming digit, form pairs with all previously buffered digits (earlier position as tens digit, later as ones digit). Track maximum across all pairs. No reordering allowed - respects original battery positions.

### Part 2: Software Solution (Greedy Algorithm)

Greedy selection algorithm in OCaml:
- For each output position, find the largest digit we can take
- Must ensure enough digits remain for remaining positions
- Time complexity: O(n×k) where n=line length, k=12

## Building & Running

### Prerequisites
```bash
# Install OCaml and dependencies
opam install dune hardcaml ppx_jane bignum
```

### Build
```bash
dune build
```

### Run Tests
```bash
dune test
```

### Solve Part 1
```bash
dune exec bin/solve.exe < input.txt
```

### Solve Part 2
```bash
dune exec bin/solve_part2.exe < input.txt
```

## Project Structure
```
.
├── src/
│   ├── range_finder.ml      # Part 1: Hardcaml RTL design
│   └── range_finder.mli     # Module interface
├── bin/
│   ├── solve.ml             # Part 1: Solver using hardware simulation
│   └── solve_part2.ml       # Part 2: Greedy algorithm solver
├── test/
│   └── test_range_finder.ml # Unit tests with expect tests
├── dune-project               # Dune project configuration
├── README.md                  # This file
└── input.txt                  # Puzzle input
```

## Hardware Design Details

### I/O Interface

**Inputs:**
- `clock`: System clock
- `clear`: Synchronous reset
- `digit[3:0]`: Input digit stream (0-9)
- `digit_valid`: Indicates valid digit on input
- `line_end`: Pulse to mark end of battery bank

**Outputs:**
- `max_joltage[6:0]`: Maximum joltage for last completed line (0-99)
- `total_joltage[31:0]`: Running total across all lines

### Synthesis Considerations

**Target FPGAs:** Xilinx 7-Series, UltraScale, Intel Cyclone/Stratix, Lattice ECP5

**Estimated Resources (Xilinx 7-Series):**
- LUTs: ~500
- FFs: ~650
- Block RAM: 0
- DSP Blocks: 0

**Timing:**
- Critical path: Comparison tree + mux selection (~3-4ns)
- Expected Fmax: 200-250 MHz

**Power:** Minimal, dominated by buffer register switching

### Design Trade-offs

1. **Buffer Size vs Area:** 120 digits handles all puzzle inputs; could be parameterized
2. **Comparison Strategy:** Check all pairs on each digit for simplicity vs. sorting network
3. **Parallelism:** Serial processing minimizes area; could parallelize for higher throughput
4. **Numeric Precision:** 7-bit joltage (max 99), 32-bit accumulator (handles millions of lines)


## Testing

Comprehensive test coverage:
- ✅ Example inputs (expect tests)
- ✅ Edge cases (single digit lines, all same digits)
- ✅ Buffer overflow handling
- ✅ Reset behavior
- ✅ Accumulator correctness

Run tests with:
```bash
dune test
```

## Alternative Approaches Considered

### Part 1 Alternatives

1. **Sorting Network:** Sort all digits, pick top 2
   - ❌ Requires O(n log n) comparators
   - ❌ More complex than needed

2. **Two-Pass:** Store entire line, then find maximum
   - ❌ Requires memory
   - ❌ Adds latency

3. **Parallel Pair Check:** Check all pairs simultaneously
   - ❌ O(n²) area cost
   - ✅ Could achieve higher throughput

**Chosen approach balances area efficiency with reasonable throughput.**

### Part 2 Approach

Software greedy algorithm chosen over hardware because:
- 12-digit numbers require 40+ bit arithmetic
- Variable-length output complicates RTL
- Greedy algorithm is simple and efficient in software
- Still demonstrates algorithmic thinking



## Learning Resources

- [Hardcaml Documentation](https://github.com/janestreet/hardcaml)
- [Jane Street Blog: Advent of Hardcaml](https://blog.janestreet.com/)
- [Advent of Code 2025](https://adventofcode.com/2025)

## Submission

**Submitted for:** Jane Street Advent of FPGA 2025 Challenge  
**Puzzle:** Day 3 (Parts 1 & 2)  
**Language:** Hardcaml (OCaml-based HDL) + OCaml  


## Author

**Kaileshwar**  
GitHub: [@Kaileshwar16](https://github.com/Kaileshwar16)

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Jane Street for the Advent of FPGA challenge and Hardcaml
- Eric Wastl for Advent of Code
- The OCaml and FPGA communities

---

*"Hardware design meets functional programming"*
