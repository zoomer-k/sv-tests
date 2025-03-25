#!/bin/bash
set -euxo pipefail
set -x
set -e

#environment variables for this file are set in sv-tests-ci.yml

# Get base report from sv-tests master run
REPORTS_HISTORY=$(mktemp -d --suffix='.history')
BASE_REPORT="${}/report.csv"
git clone https://github.com/chipsalliance/sv-tests-results.git --depth 120 "$REPORTS_HISTORY"

# Create the directory if it doesn't exist
mkdir -p "$(dirname "$COMPARE_REPORT")"
mkdir -p "$(dirname "$OUT_REPORT_DIR")"
mkdir -p "$(dirname "$REPORTS_HISTORY")"


# Delete headers from all report.csv
for file in $(find ./out/report_* -name "*.csv" -print); do
	sed -i.backup 1,1d $file
done

# concatenate test reports
cat $(find ./out/report_* -name "*.csv" -print) >> $COMPARE_REPORT

# Insert header at the first line of concatenated report
sed -i 1i\ $(head -1 $(find ./out/report_* -name "*.csv.backup" -print -quit)) $COMPARE_REPORT

#python $ANALYZER $COMPARE_REPORT $BASE_REPORT -o $CHANGES_SUMMARY_JSON -t $CHANGES_SUMMARY_MD
python tools/report_analyzer.py "$COMPARE_REPORT" "$BASE_REPORT" -o "$CHANGES_SUMMARY_JSON" -t "$CHANGES_SUMMARY_MD"

# generate history graph
python $GRAPHER -n 120 -r $REPORTS_HISTORY

set +e
set +x
