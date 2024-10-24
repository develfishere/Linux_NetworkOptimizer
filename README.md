# Linux Network Optimizer v0.3

This repository contains a **Bash script** designed to enhance network performance on Linux systems

The script intelligently optimizes network settings based on your **system's hardware specifications** (**CPU**, **RAM**) and current **network speed**

It dynamically selects and implements the most suitable queuing discipline from **fq**, **fq_codel**, or **cake**, and uses the **BBR** (Bottleneck Bandwidth and Round-trip propagation time) congestion control algorithm for optimal performance

- If you prefer, you can refer to the [Persian Readme](./README_FA.md)

- Additionally, the [Changelog](./CHANGELOG.md) is available at the provided link.

## Key Features

- Dynamically selects and configures queuing disciplines (`fq`, `fq_codel`, `cake`) based on system resources to minimize latency
- Implements `BBR` congestion control for optimal throughput and low latency
- Adjusts TCP buffer sizes (`tcp_rmem`, `tcp_wmem`) based on system CPU, RAM, and network speed
- Performs network benchmarking using `ookla speedtest` to inform dynamic network tuning
- Optimizes `netdev_max_backlog` and memory buffers for handling high volumes of TCP connections
- Provides automatic backup and restoration of original network settings

## Prerequisites

### 1. Ensure that the `sudo`, `curl`, and `jq` packages are installed on your system

#### Ubuntu & Debian

```bash
sudo apt update && sudo apt install -y sudo curl jq
```

### 2. The script requires root privileges. If you're not logged in as root, use the following command

```bash
sudo -i
```

### 3. Ookla Speedtest

#### The script will automatically install Ookla Speedtest CLI if it's not already installed. However, if you prefer to install it manually, you can use the following command

```bash
sudo apt-get install curl
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
```

####

## How to Use

Run the following command to update your system and execute the optimization script

```bash
sudo apt update && bash <(curl -Ls https://raw.githubusercontent.com/develfishere/Linux_NetworkOptimizer/main/bbr.sh --ipv4)
```

## Support

If you encounter any issues or have suggestions, feel free to open an issue in the [GitHub Issues section](https://github.com/develfishere/Linux_NetworkOptimizer/issues)

## Disclaimer

This script is provided "as is," without any guarantees or warranties. Use it at your own risk.

## License

This project is licensed under the MIT License.
