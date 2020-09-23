Output of `./repro.sh`

```
+ bazel build collect a b
Loading: 
Loading: 0 packages loaded
INFO: Build option --define has changed, discarding analysis cache.
Analyzing: 3 targets (0 packages loaded, 0 targets configured)
DEBUG: /private/var/tmp/_bazel_segiddins/d67a5c429b136a9e80878423f6fc7f4f/external/bazel_tools/tools/osx/xcode_configure.bzl:89:14: Invoking xcodebuild failed, developer dir: /Applications/Xcode-9.4.app/Contents/Developer ,return code 134, stderr: , stdout: 
INFO: Analyzed 3 targets (0 packages loaded, 271 targets configured).
INFO: Found 3 targets...
INFO: Writing explanation of rebuilds to 'bazel-explain.txt'
[0 / 6] [Prepa] BazelWorkspaceStatusAction stable-status.txt ... (3 actions, 0 running)
Target //:collect up-to-date:
  bazel-out/applebin_ios-ios_x86_64-dbg-ST-e763699e1aa1/bin/a_config.txt
  bazel-out/applebin_ios-ios_x86_64-dbg-ST-e763699e1aa1/bin/b_config.txt
  bazel-out/ios-x86_64-min10.0-applebin_ios-ios_x86_64-dbg/bin/libmain.a
Target //:a up-to-date:
  bazel-out/applebin_ios-ios_x86_64-dbg-ST-f15c78a5cd43/bin/a_config.txt
Target //:b up-to-date:
  bazel-out/applebin_ios-ios_x86_64-dbg-ST-f15c78a5cd43/bin/a_config.txt
  bazel-out/applebin_ios-ios_x86_64-dbg-ST-f15c78a5cd43/bin/b_config.txt
INFO: Elapsed time: 0.352s, Critical Path: 0.04s
INFO: 4 processes: 4 local.
INFO: Build completed successfully, 5 total actions
INFO: Build completed successfully, 5 total actions
INFO: Build Event Protocol files produced successfully.
INFO: Build completed successfully, 5 total actions
 

	Notice that there are 2 paths to {a,b}_config.txt! This is bad, there should only be one



+ bazel build collect a b --define=pls_fail=1 --build_event_json_file=bep.json-stream
Loading: 
Loading: 0 packages loaded
INFO: Build option --define has changed, discarding analysis cache.
Analyzing: 3 targets (0 packages loaded, 0 targets configured)
DEBUG: /private/var/tmp/_bazel_segiddins/d67a5c429b136a9e80878423f6fc7f4f/external/bazel_tools/tools/osx/xcode_configure.bzl:89:14: Invoking xcodebuild failed, developer dir: /Applications/Xcode-9.4.app/Contents/Developer ,return code 134, stderr: , stdout: 
INFO: Analyzed 3 targets (0 packages loaded, 271 targets configured).
INFO: Found 3 targets...
INFO: Writing explanation of rebuilds to 'bazel-explain.txt'
[0 / 6] [Prepa] BazelWorkspaceStatusAction stable-status.txt
ERROR: /Users/segiddins/Desktop/BazelConfigs/BUILD.bazel:3:13: Couldn't build file a_config.txt: error executing shell command: '/bin/bash -c readonly output=$1; shift; readonly es=$1; shift; echo $@ > ${output}; exit ${es}  bazel-out/applebin_ios-ios_x86_64-dbg-ST-e763699e1aa1/bin/a_config.txt 1 bazel-out/applebin_ios-ios_x...' failed (Exit 1)
ERROR: /Users/segiddins/Desktop/BazelConfigs/BUILD.bazel:3:13: Couldn't build file a_config.txt: error executing shell command: '/bin/bash -c readonly output=$1; shift; readonly es=$1; shift; echo $@ > ${output}; exit ${es}  bazel-out/applebin_ios-ios_x86_64-dbg-ST-f15c78a5cd43/bin/a_config.txt 1 bazel-out/applebin_ios-ios_x...' failed (Exit 1)
ERROR: /Users/segiddins/Desktop/BazelConfigs/BUILD.bazel:7:13: Couldn't build file b_config.txt: error executing shell command: '/bin/bash -c readonly output=$1; shift; readonly es=$1; shift; echo $@ > ${output}; exit ${es}  bazel-out/applebin_ios-ios_x86_64-dbg-ST-f15c78a5cd43/bin/b_config.txt 1 bazel-out/applebin_ios-ios_x...' failed (Exit 1)
ERROR: /Users/segiddins/Desktop/BazelConfigs/BUILD.bazel:7:13: Couldn't build file b_config.txt: error executing shell command: '/bin/bash -c readonly output=$1; shift; readonly es=$1; shift; echo $@ > ${output}; exit ${es}  bazel-out/applebin_ios-ios_x86_64-dbg-ST-e763699e1aa1/bin/b_config.txt 1 bazel-out/applebin_ios-ios_x...' failed (Exit 1)
Target //:collect failed to build
Target //:a failed to build
Target //:b failed to build
Use --verbose_failures to see the command lines of failed build steps.
INFO: Elapsed time: 0.266s, Critical Path: 0.04s
INFO: 0 processes.
FAILED: Build did NOT complete successfully
FAILED: Build did NOT complete successfully
INFO: Build Event Protocol files produced successfully.
FAILED: Build did NOT complete successfully
+ bazel config 1908601e8157a3765e39ede2fc98d23c9c1be24080e5589fc71fa6a15d7d9ff1 28e83bd7c518774a6378a7ee5024c969ab10fdacb062577d0f528bb70b3e6917
INFO: Displaying diff between configs 1908601e8157a3765e39ede2fc98d23c9c1be24080e5589fc71fa6a15d7d9ff1 and 28e83bd7c518774a6378a7ee5024c969ab10fdacb062577d0f528bb70b3e6917
Displaying diff between configs 1908601e8157a3765e39ede2fc98d23c9c1be24080e5589fc71fa6a15d7d9ff1 and 28e83bd7c518774a6378a7ee5024c969ab10fdacb062577d0f528bb70b3e6917
FragmentOptions com.google.devtools.build.lib.analysis.config.CoreOptions {
  affected by starlark transition: [apple_split_cpu], [apple configuration distinguisher, cpu, ios_minimum_os]
  transition directory name fragment: ST-e763699e1aa1, ST-f15c78a5cd43
}
 

	Notice that there is no real difference between the configs, other than the set of options 'affected by starlark transition'
```