# Linux Network Optimizer v0.2

[Persian Readme](./README_FA.md)

This repository contains a **Bash script** designed to enhance network performance on Linux systems

The script intelligently optimizes network settings based on your **system's hardware specifications** (**CPU**, **RAM**) and current **network speed**

It dynamically selects and implements the most suitable queuing discipline from **fq**, **fq_codel**, or **cake**, and uses the **BBR** (Bottleneck Bandwidth and Round-trip propagation time) congestion control algorithm for optimal performance

## Key Features

- Dynamically selects and configures queuing disciplines (`fq`, `fq_codel`, `cake`) based on system resources to minimize latency
- Implements `BBR` congestion control for optimal throughput and low latency
- Adjusts TCP buffer sizes (`tcp_rmem`, `tcp_wmem`) based on system CPU, RAM, and network speed
- Performs network benchmarking using `speedtest-cli` to inform dynamic network tuning
- Optimizes `netdev_max_backlog` and memory buffers for handling high volumes of TCP connections
- Provides automatic backup and restoration of original network settings

## Changelog

<details>
  <summary><strong>v0.2 - 2024-10-22</strong></summary>

### Added

- Introduced dynamic selection of queuing disciplines (`fq`, `fq_codel`, `cake`) based on system resources (RAM and CPU)
  - **Low-end systems**: Uses `fq_codel` for reduced latency
  - **Medium-end systems**: Uses `fq` for balanced performance
  - **High-end systems**: Uses `cake` for advanced queue management and optimal performance in high-traffic scenarios
- Improved TCP memory buffer and backlog settings:
  - Dynamically adjusts `rmem_max`, `wmem_max`, and `netdev_max_backlog` based on system resources (RAM and CPU)
- Enhanced network tuning based on network speed:
  - Automatically configures `tcp_rmem` and `tcp_wmem` for different network speeds to optimize throughput and reduce latency

### Changed

- Set default queuing discipline via `net.core.default_qdisc` dynamically based on system benchmarks
- Retained `bbr` as the default TCP congestion control algorithm for optimal throughput and low latency
- Updated sysctl logging mechanism to capture queuing discipline choices and dynamically tuned network settings

### Fixed

- Prevented redundant backup creation of `/sysctl.conf` if a backup already exists, streamlining the configuration process

### Other

- Improved inline comments and log messaging for better readability and tracking of dynamic system adjustments

</details>

## Prerequisites

### Ensure that the `sudo` and `curl` packages are installed on your system

#### Ubuntu & Debian

```bash
sudo apt update -q && sudo apt install -y sudo curl
```

### The script requires root privileges. If you're not logged in as root, use the following command

```bash
sudo -i
```

## How to Use

Run the following command to update your system and execute the optimization script

```bash
sudo apt update && sudo apt upgrade -y && bash <(curl -Ls https://raw.githubusercontent.com/develfishere/Linux_NetworkOptimizer/main/bbr.sh --ipv4)
```

## Support

If you encounter any issues or have suggestions, feel free to open an issue in the [GitHub Issues section](https://github.com/develfishere/Linux_NetworkOptimizer/issues)

## Disclaimer

This script is provided "as is," without any guarantees or warranties. Use it at your own risk.

## License

This project is licensed under the MIT License.
