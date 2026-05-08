# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
import os
import subprocess
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent

MICROMAMBA_URL = "https://micro.mamba.pm/api/micromamba/linux-64/latest"
MAMBA_ROOT = Path("/tmp/mamba")
ENV_PREFIX = MAMBA_ROOT / "env"
MICROMAMBA_BIN = MAMBA_ROOT / "bin" / "micromamba"
ENVIRONMENT_YML = PROJECT_DIR / "environment.yml"


def run(
    cmd: list[str],
    *,
    env: dict[str, str] | None = None,
    cwd: Path | None = None,
) -> None:
    """Run a command, streaming stdout/stderr line-by-line in real time."""
    print(f">>> {' '.join(cmd)}", flush=True)
    proc = subprocess.Popen(
        cmd,
        env=env,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    assert proc.stdout is not None
    for line in proc.stdout:
        print(line, end="", flush=True)
    returncode = proc.wait()
    if returncode != 0:
        raise SystemExit(
            f"\nCommand failed with exit code {returncode}: {' '.join(cmd)}"
        )


def install_micromamba() -> None:
    """Download micromamba static binary to /tmp."""
    MAMBA_ROOT.mkdir(parents=True, exist_ok=True)
    run(
        [
            "sh",
            "-c",
            f"curl -Ls {MICROMAMBA_URL} | tar -xvj -C {MAMBA_ROOT} bin/micromamba",
        ]
    )
    print(f"micromamba installed to {MICROMAMBA_BIN}", flush=True)


def install_environment() -> None:
    """Create a conda environment with R and packages from environment.yml."""
    run(
        [
            str(MICROMAMBA_BIN),
            "create",
            "-y",
            "-p",
            str(ENV_PREFIX),
            "-f",
            str(ENVIRONMENT_YML),
        ]
    )
    print("R environment created.", flush=True)


def r_env() -> dict[str, str]:
    """Build environment for running R from the conda prefix."""
    env = os.environ.copy()
    env["PATH"] = f"{ENV_PREFIX / 'bin'}:{env.get('PATH', '')}"
    env["R_HOME"] = str(ENV_PREFIX / "lib" / "R")
    env["LD_LIBRARY_PATH"] = f"{ENV_PREFIX / 'lib'}:{env.get('LD_LIBRARY_PATH', '')}"
    return env


def start_app() -> None:
    """Start the Shiny app, replacing the current process."""
    env = r_env()
    app_script = str(PROJECT_DIR / "app" / "app.R")
    rscript = str(ENV_PREFIX / "bin" / "Rscript")
    os.execvpe(rscript, ["Rscript", "--vanilla", app_script], env)


def main() -> None:
    install_micromamba()
    install_environment()
    start_app()


if __name__ == "__main__":
    main()
