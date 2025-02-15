# CHANGELOG
## v0.7 - 2025-02-16

### Fixed

- Minor bugs and stability improvements.
- Optimizations for lossy and unstable network

## v0.6 - 2024-11-30

### Fixed

- Removed tcp optimization based on speedtest due to instability
- Optimization to set force apt to use IPv4 by default

## v0.5 - 2024-11-01

### Fixed

- Removed `fq` queuing algorithm and replaced `cake` with that for better performance

## v0.4 - 2024-10-31

### Added

- Configure and fix server hosts and DNS settings.
- Implement function to find the optimal MTU size for improved network performance.

### Fixed

- Enforce `apt update` and `apt upgrade` commands to use IPv4 to prevent connectivity issues on IPv6.

## v0.3 - 2024-10-24

### Added

- Added logic to check for existing or incompatible versions of `speedtest-cli` and remove them before installing the Ookla Speedtest CLI.
- Added failure handling for cases where Ookla Speedtest CLI installation via `apt` fails, logging the error and exiting the script instead of assuming a default speed.
- Provided manual installation instructions for Ookla Speedtest CLI in the README file.
- The script now ensures a full system update and upgrade before installing required dependencies to avoid package conflicts or outdated software.

## v0.2 - 2024-10-23

### Added

- Introduced dynamic selection of queuing disciplines (`fq`, `fq_codel`, `cake`) based on system resources (RAM and CPU):
  - **Low-end systems**: Uses `fq_codel` for reduced latency.
  - **Medium-end systems**: Uses `fq` for balanced performance.
  - **High-end systems**: Uses `cake` for advanced queue management and optimal performance in high-traffic scenarios.
- Improved TCP memory buffer and backlog settings:
  - Dynamically adjusts `rmem_max`, `wmem_max`, and `netdev_max_backlog` based on system resources (RAM and CPU).
- Enhanced network tuning based on network speed:
  - Automatically configures `tcp_rmem` and `tcp_wmem` for different network speeds to optimize throughput and reduce latency.

### Changed

- Set default queuing discipline via `net.core.default_qdisc` dynamically based on system benchmarks.
- Retained `bbr` as the default TCP congestion control algorithm for optimal throughput and low latency.
- Updated sysctl logging mechanism to capture queuing discipline choices and dynamically tuned network settings.

### Fixed

- Prevented redundant backup creation of `/sysctl.conf` if a backup already exists, streamlining the configuration process.

### Other

- Improved inline comments and log messaging for better readability and tracking of dynamic system adjustments.
