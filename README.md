# Flush+Reload

Implementation of the Flush+Reload cache side-channel attack as descibed by Yuval Yarom and Katrina Falkner in [this](https://www.usenix.org/system/files/conference/usenixsecurity14/sec14-paper-yarom.pdf) paper adopted from [r0-l](https://github.com/r0-l/Flush-Reload).

### Steps

1. Calibrate the spying programs according your own processor. Tweak the `THRESHOLD` macro as per the results of `calibration` program in `./calibration`.
2. Get the relevant address to spy on from the `abcd` binary in `./target_program`.
3. Spy the chosen address(es) using either `single_probe_spy` or `multi_probe_spy utility`. Multi-probe spy is capable of monitoring multiple addresses simultaneously.
