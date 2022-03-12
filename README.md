<h1 align="center">
  <img src="https://upload.wikimedia.org/wikipedia/en/3/37/Logo_of_Trackmania_%282020%29.png" alt="Trackmania">
  <br />
  Trackmania 2020 for Ubuntu</i>
</h1>

<p align="center"><b>This is an install script and launcher for Trackmania 2020</b>, <i>"a racing video game and is part of the TrackMania series.</i> It works on Ubuntu and derivative distributions.
<br />
Made with 💝 for <img src=".github/ubuntu.png" align="top" width="18" /></p>

## Install

The first time you run `tm2020.sh` it will download [UbisoftConnect](https://ubisoftconnect.com/en-GB/), [Wine-GE](https://github.com/gloriouseggroll/wine-ge-custom) and [Wine-Staging](https://wiki.winehq.org/Wine-Staging) to
create an isolated environment in `~/Games/TM2020`.

```bash
git clone https://github.com/wimpysworld/trackmania-2020-ubuntu.git
cd trackmania-2020-ubuntu
./tm2020.sh
```

  * Login to, or create an account for, Ubisoft Connect when it launches so you can download the game.

## Launcher

Subsequent executions of `tm2020.sh` will launch `Trackmania.exe` directly.

```bash
./tm2020.sh
```
