# Monitoring Logs Directory

This directory contains real-time monitoring logs from MAMBA framework script executions, as specified in **MP099: Real-Time Progress Reporting**.

## Directory Structure

- **`etl/`** - Logs from ETL pipeline scripts (0IM, 1ST, 2TR phases)
- **`api/`** - Logs from API interaction scripts
- **`database/`** - Logs from database operation scripts  
- **`general/`** - Logs from other scripts

## Log File Naming Convention

Logs follow this naming pattern:
```
monitor_[script_name]_[YYYYMMDD]_[HHMMSS].log
```

Example: `monitor_cbz_ETL01_0IM.R_20250828_143025.log`

## Usage

### Automatic Monitoring (R)
```r
source("scripts/global_scripts/04_utils/fn_monitor_r_script.R")
result <- monitor_r_script("path/to/script.R")
```

### Shell-Based Monitoring
```bash
scripts/global_scripts/04_utils/fn_run_r_monitored.sh path/to/script.R
```

### Real-Time Monitoring for Claude Code
```bash
stdbuf -oL -eL Rscript script.R 2>&1 | tee etl/monitor.log &
```

## Log Contents

Monitoring logs capture:
- Progress messages with timestamps
- Error messages with context
- Warning counts
- Performance metrics (execution time, memory usage)
- Exit status codes

## Log Retention

Logs are preserved for debugging and audit purposes. Consider implementing log rotation if the directory grows too large.

## Related Documentation

- MP099: Real-Time Progress Reporting principle
- See `../2025-08-28_monitoring_log_relocation.md` for migration details