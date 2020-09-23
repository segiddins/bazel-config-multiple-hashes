def _cpu_string(platform_type, settings):
    """Generates a <platform>_<arch> string for the current target based on the given parameters."""
    if platform_type == "ios":
        ios_cpus = settings["//command_line_option:ios_multi_cpus"]
        if ios_cpus:
            return "ios_{}".format(ios_cpus[0])
        cpu_value = settings["//command_line_option:cpu"]
        if cpu_value.startswith("ios_"):
            return cpu_value
        return "ios_x86_64"
    if platform_type == "macos":
        macos_cpus = settings["//command_line_option:macos_cpus"]
        if macos_cpus:
            return "darwin_{}".format(macos_cpus[0])
        return "darwin_x86_64"
    if platform_type == "tvos":
        tvos_cpus = settings["//command_line_option:tvos_cpus"]
        if tvos_cpus:
            return "tvos_{}".format(tvos_cpus[0])
        return "tvos_x86_64"
    if platform_type == "watchos":
        watchos_cpus = settings["//command_line_option:watchos_cpus"]
        if watchos_cpus:
            return "watchos_{}".format(watchos_cpus[0])
        return "watchos_i386"

def _tr_impl(settings, attr):
    ret = {
        "//command_line_option:apple configuration distinguisher": "applebin_ios",
        "//command_line_option:apple_platform_type": settings["//command_line_option:apple_platform_type"],
        "//command_line_option:apple_split_cpu": "",
        "//command_line_option:compiler": settings["//command_line_option:apple_compiler"],
        "//command_line_option:cpu": _cpu_string("ios", settings),
        "//command_line_option:crosstool_top": (
            settings["//command_line_option:apple_crosstool_top"]
        ),
        "//command_line_option:fission": [],
        "//command_line_option:grte_top": settings["//command_line_option:apple_grte_top"],
        "//command_line_option:ios_minimum_os": "10.0",
        "//command_line_option:macos_minimum_os": None,
        "//command_line_option:tvos_minimum_os": None,
        "//command_line_option:watchos_minimum_os": None,
    }
    return ret

_tr = transition(
    implementation = _tr_impl,
    inputs = [
        "//command_line_option:apple_compiler",
        "//command_line_option:apple_crosstool_top",
        "//command_line_option:apple_platform_type",
        "//command_line_option:apple_grte_top",
        "//command_line_option:cpu",
        "//command_line_option:ios_multi_cpus",
        "//command_line_option:macos_cpus",
        "//command_line_option:tvos_cpus",
        "//command_line_option:watchos_cpus",
    ],
    outputs = [
        "//command_line_option:apple configuration distinguisher",
        "//command_line_option:apple_platform_type",
        "//command_line_option:apple_split_cpu",
        "//command_line_option:compiler",
        "//command_line_option:cpu",
        "//command_line_option:crosstool_top",
        "//command_line_option:fission",
        "//command_line_option:grte_top",
        "//command_line_option:ios_minimum_os",
        "//command_line_option:macos_minimum_os",
        "//command_line_option:tvos_minimum_os",
        "//command_line_option:watchos_minimum_os",
    ],
)

def _bool_value(ctx, define_name, default):
    """Looks up a define on ctx for a boolean value.

    Will also report an error if the value is not a supported value.

    Args:
      ctx: A Starlark context.
      define_name: The name of the define to look up.
      default: The value to return if the define isn't found.

    Returns:
      True/False or the default value if the define wasn't found.
    """
    value = ctx.var.get(define_name, None)
    if value != None:
        if value.lower() in ("true", "yes", "1"):
            return True
        if value.lower() in ("false", "no", "0"):
            return False
        fail("Valid values for --define={} are: true|yes|1 or false|no|0.".format(
            define_name,
        ))
    return default

def _print_config_impl(ctx):
    output = ctx.actions.declare_file("{}_config.txt".format(ctx.label.name))
    input_files = [d[DefaultInfo].files for d in ctx.attr.deps]
    ctx.actions.run_shell(
        command = "readonly output=$1; shift; readonly es=$1; shift; echo $@ > ${output}; exit ${es}",
        arguments = [
            ctx.actions.args().add(output).add(1 if _bool_value(ctx, "pls_fail", 0) else 0).add(ctx.genfiles_dir.path).add_all(depset(transitive = input_files)),
        ],
        outputs = [output],
    )
    return [
        DefaultInfo(files = depset(direct = [output], transitive = input_files)),
        apple_common.new_objc_provider(),
    ]

print_config = rule(
    implementation = _print_config_impl,
    cfg = _tr,
    fragments = ["apple"],
    attrs = {
        "deps": attr.label_list(),
        "_whitelist_function_transition": attr.label(default = "@bazel_tools//tools/whitelists/function_transition_whitelist"),
    },
)

Data = provider()

def _collect_data_impl(target, ctx):
    data = Data(
        files = depset(direct = getattr(ctx.rule.files, "deps", []), transitive = [d[Data].files for d in ctx.rule.attr.deps]),
    )
    return [data]

_collect_data = aspect(
    implementation = _collect_data_impl,
    attr_aspects = ["deps"],
)

def _collect_impl(ctx):
    return [
        DefaultInfo(files = depset(transitive = [d[Data].files for d in ctx.attr.deps])),
    ]

collect = rule(
    implementation = _collect_impl,
    attrs = {
        "deps": attr.label_list(aspects = [_collect_data]),
    },
)
