"""Run every finite exact check and probe, preserving child exit statuses."""
import argparse
import json
import pathlib
import subprocess
import sys
import time

SCRIPTS = ["conj.py", "conj2.py", "verify.py", "verify2.py", "structure.py",
           "probe2.py", "sharpness.py", "pureZ_check.py", "audit_checks.py"]


def positive_seconds(value):
    seconds = float(value)
    if not 0 < seconds < float("inf"):
        raise argparse.ArgumentTypeError("timeout must be a finite positive number")
    return seconds


def main(argv=None):
    if not __debug__:
        raise RuntimeError("Run without -O: assertions are part of the verifier")
    root = pathlib.Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=pathlib.Path, default=root / "results",
                        help="local transcript directory (default: verification/results)")
    parser.add_argument("--timeout", type=positive_seconds, default=180,
                        help="per-script timeout in seconds (default: 180)")
    args = parser.parse_args(argv)
    output = args.output_dir
    output.mkdir(parents=True, exist_ok=True)

    scripts_on_disk = {path.name for path in root.glob("*.py") if path.name != "run_all.py"}
    if scripts_on_disk != set(SCRIPTS) or len(SCRIPTS) != len(set(SCRIPTS)):
        raise RuntimeError("SCRIPTS must list every other verification/*.py exactly once")

    results = []
    for name in SCRIPTS:
        started = time.monotonic()
        log = output / (name + ".txt")
        try:
            result = subprocess.run([sys.executable, str(root/name)], capture_output=True,
                                    text=True, encoding="utf-8", errors="replace",
                                    timeout=args.timeout)
            transcript = result.stdout + "\nSTDERR:\n" + result.stderr
            log.write_text(transcript, encoding="utf-8")
            entry = {"script": name, "exit_code": result.returncode,
                     "seconds": round(time.monotonic()-started, 3),
                     "log": log.name}
        except subprocess.TimeoutExpired as error:
            # TimeoutExpired can carry bytes even when text=True was requested.
            def as_text(value):
                return value.decode("utf-8", errors="replace") if isinstance(value, bytes) else value or ""
            log.write_text(as_text(error.stdout) + "\nSTDERR:\n" + as_text(error.stderr)
                           + "\nTIMEOUT\n", encoding="utf-8")
            entry = {"script": name, "exit_code": None,
                     "timeout_seconds": args.timeout, "log": log.name}
        results.append(entry)
        print(json.dumps(entry), flush=True)
    passed = all(item["exit_code"] == 0 for item in results)
    report = {"status": "PASS_FINITE_CHECKS" if passed else "FAIL", "python": sys.version,
              "results": results,
              "limitations": "Finite exact computations do not prove the universal conjecture or general sharpness."}
    (output/"results.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
    print(report["status"], flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
