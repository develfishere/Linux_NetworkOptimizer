# Linux Network Optimizer v0.7

This repository contains a **Bash script** designed to enhance network performance on Linux systems

The script intelligently optimizes network settings based on your **system's hardware specifications** (**CPU**, **RAM**)

It dynamically selects and implements the most suitable queuing discipline from **fq_codel** or **cake**, and uses the **BBR** (Bottleneck Bandwidth and Round-trip propagation time) congestion control algorithm for optimal performance

- If you prefer, you can refer to the [Persian Readme](./README_FA.md)

- Additionally, the [Changelog](./CHANGELOG.md) is available at the provided link.

## Key Features

- Dynamically selects and configures queuing disciplines (`fq_codel`, `cake`) based on system resources to minimize latency
- Implements `BBR` congestion control for optimal throughput and low latency
- Adjusts TCP buffer sizes (`tcp_rmem`, `tcp_wmem`) based on system CPU and RAM
- Optimizes `netdev_max_backlog` and memory buffers for handling high volumes of TCP connections
- Find the optimal `MTU` size for improved network performance
- Provides automatic backup and restoration of original network settings

## Prerequisites

### The script requires root privileges. If you're not logged in as root, use the following command

```bash
sudo -i
```

####

## How to Use

Run the following command to update your system, install required packages, and execute the optimization script

```bash
sudo apt-get -o Acquire::ForceIPv4=true update && \
sudo apt-get -o Acquire::ForceIPv4=true install -y sudo curl jq && \
bash <(curl -Ls --ipv4 https://raw.githubusercontent.com/develfishere/Linux_NetworkOptimizer/main/bbr.sh)
```

## Support

If you encounter any issues or have suggestions, feel free to open an issue in the [GitHub Issues section](https://github.com/develfishere/Linux_NetworkOptimizer/issues)

## Disclaimer

This script is provided "as is," without any guarantees or warranties. Use it at your own risk.

## License

This project is licensed under the MIT License.
