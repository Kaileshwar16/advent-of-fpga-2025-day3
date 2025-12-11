# Advent of FPGA 2025 - Day 3: Battery Joltage Calculator

**Hardcaml Solution for Jane Street's Advent of FPGA Challenge**

## Problem

Given battery banks (lines of digits 1-9), find the maximum 2-digit joltage each bank can produce by selecting exactly two batteries in their original positions. Sum all maximum joltages.

### Example
```
987654321111111 → 98 jolts (positions 0,1: digits 9,8)
811111111111119 → 89 jolts (positions 0,14: digits 8,9)
234234234234278 → 78 jolts (positions 12,13: digits 7,8)
818181911112111 → 92 jolts (positions 6,11: digits 9,2)
Total: 357
```

## Solution

Streaming hardware architecture in **Hardcaml** that:
- Buffers up to 120 digits per line
- Checks all pairs on-the-fly as digits arrive
- Tracks maximum joltage per line
- Accumulates total across all lines

### Key Features
- ✅ Fully synthesizable RTL
- ✅ ~500 LUTs estimated
- ✅ No block RAM required
- ✅ Processes 1 digit per clock cycle
- ✅ Handles lines up to 120 digits

## Building
```bash
# Install dependencies
opam install dune hardcaml ppx_jane

# Build
dune build

# Run tests
dune test

# Solve puzzle
dune exec bin/solve.exe < input.txt
```

## Project Structure
```
.
├── src/
│   ├── range_finder.ml      # Main RTL design
│   └── range_finder.mli     # Module interface
├── bin/
│   └── solve.ml             # Solver executable
├── test/
│   └── test_range_finder.ml # Unit tests
└── README.md
```

## Hardware Architecture

**I/O Interface:**
- Input: `digit[3:0]`, `digit_valid`, `line_end`, `clock`, `clear`
- Output: `max_joltage[6:0]`, `total_joltage[31:0]`

**Resources:**
- 120×4-bit digit buffer
- 8-bit counter
- 7-bit max tracker
- 32-bit accumulator

**Algorithm:** For each new digit, form pairs with all previously buffered digits (earlier digit as tens, later as ones), find maximum, update best.

## Results

- Example input: **357** ✅
- My puzzle input: **17301** ✅

## Submission

Submitted for Jane Street's Advent of FPGA 2025 Challenge
- Language: Hardcaml (OCaml-based HDL)
- Eligible for Hardcaml T-shirt! 👕

## License

MIT
