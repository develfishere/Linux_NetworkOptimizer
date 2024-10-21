# Linux Network Optimizer v0.1

This repository contains a **Bash script** designed to enhance network performance on Linux systems.

The script intelligently optimizes network settings based on your **system's hardware specifications** and current **network speed**. It implements the **BBR** (Bottleneck Bandwidth and Round-trip propagation time) and **FQ** (Fair Queue) congestion control algorithms.

## Key Features

- Implements BBR and FQ congestion control algorithms.
- Dynamically adjusts TCP buffer sizes according to the system's CPU, RAM, and network speed.
- Performs network benchmarking using `speedtest-cli`.
- Provides backup and restoration of the original network settings.

## Prerequisites

### Ensure that the `sudo` and `wget` packages are installed on your system

- Ubuntu & Debian:

```bash
sudo apt update -q && sudo apt install -y sudo wget
```

### The script requires root privileges. If you're not logged in as root, use the following command

```bash
sudo -i
```

## How to Use

Run the following command to update your system and execute the optimization script:

```bash
sudo apt update && sudo apt upgrade -y && bash <(curl -Ls https://raw.githubusercontent.com/develfishere/Linux_NetworkOptimizer/main/bbr.sh --ipv4)
```

## Support

If you encounter any issues or have suggestions, feel free to open an issue in the [GitHub Issues section](https://github.com/develfishere/Linux_NetworkOptimizer/issues)

## Disclaimer

This script is provided "as is," without any guarantees or warranties. Use it at your own risk.

## License

This project is licensed under the MIT License.
