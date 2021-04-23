# Configs

[![Check all configurations](https://github.com/compassd/configs/actions/workflows/check.yaml/badge.svg)](https://github.com/compassd/configs/actions/workflows/check.yaml)
[![Join telegram channel](https://badges.aleen42.com/src/telegram.svg)](https://t.me/dcompass_channel)

This is a collaborated set of real world configuration files for dcompass.

# Usages

Under `data/` you can find all the usual data files you may find useful (IPCIDR list for China, domain list for China, etc).

Under `configs/` you can find user-contributed configuration files useful under various scenarios (e.g. circumvent DNS pollution or protect privacy).

# Examples

- dispatch-hyper: `DisableIPv6` + `AS24424-Avoid` + `Blacklist` + `ChinaDNS`

  ```bash
  dcompass -c configs/example_full.yaml
  ```

- dispatch-base: `DisableIPv6` + `ChinaDNS`

  ```bash
  dcompass -c configs/example_base.yaml
  ```

- dispatch-whitelist

  ```bash
  dcompass -c configs/example_whitelist.yaml
  ```

- dispatch-blacklist

  ```bash
  dcompass -c configs/example_blacklist.yaml
  ```

# Contribute

Just add your configuration file to `configs/`, everything will be recursively visited and checked using CI.
