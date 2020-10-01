set -euo pipefail

bazel=bazelisk

$bazel version

expect_failure() {
    (
        set +e
        $@
        st=$?
        [ $st = 0 ] && echo "Expected failure" && exit 1
        exit 0
    )
}

loudly() {
    (
        set -x
        $@
    )
}

loudly $bazel build collect a b
echo "" "\n\n\tNotice that there are 2 paths to {a,b}_config.txt! This is bad, there should only be one\n\n\n"

expect_failure loudly $bazel build collect a b --define=pls_fail=1 --build_event_json_file=bep.json-stream

cfgs=$(python -c "import json

cfgs = set()

with open('bep.json-stream', 'r') as f:
    for l in f:
        j = json.loads(l)
        id = list(j['id'].keys())[0]
        if id == 'actionCompleted' and j['action']['exitCode'] == 1:
            cfgs.add(j['action']['configuration']['id'])

if len(cfgs) == 1:
    print('Only 1 config, so its actually working!')
    exit(1)

for c in sorted(cfgs):
    print(c)")
    
loudly $bazel config ${cfgs}

echo "" "\n\n\tNotice that there is no real difference between the configs, other than the set of options 'affected by starlark transition'"
