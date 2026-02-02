# Copyright 2025 Addverb Technologies.
#
# File, directory, prefix completion with extension filter.
_fms_filedir() {
    local ext="${1}"       # File extension to filter (e.g., "map" or "xml" or "scenario")
    shift
    local prefixes=("$@")  # Array of prefixes

    # Filter files by extension
    _filedir "$ext"

    # Add prefix completion.
    for prefix in "${prefixes[@]}"; do
        if [[ -n "$prefix" ]]; then
            COMPREPLY+=( $(compgen -W "$prefix" -- "$cur") )
        fi
    done
}

# Get the current fms workspace.
function _fms_get_cws()
{
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.fmsconfig" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Handles path completion for specific options by mapping prefixes to directories and file extensions.
# To add a new option with custom prefix and file extension:
# 1. Add a new entry to the 'prefix_mapping' dictionary with the option as the key and its corresponding prefixes and directories as values.
# 2. Add the appropriate file extension for the option in the 'extension_mappings' dictionary.
_fms_handle_path_completion() {
    local cur="$1"             # Current word being completed
    local option="$2"          # Option being processed (e.g., --scene, --config)

    # Search for FMS workspace, if not exists, use '..'
    current_workspace=$(_fms_get_cws)
    if [[ -z "$current_workspace" ]]; then
        current_workspace=".."
    fi

    declare -A prefix_mapping=(
        ["--scene"]="scene://=${current_workspace}/assets/scene/ assets://=${current_workspace}/assets/ assetsTest://=${current_workspace}/assetsTest/"
        ["--scenario"]="scenario://=${current_workspace}/assets/scenario/ assets://=${current_workspace}/assets/ assetsTest://=${current_workspace}/assetsTest/"
        ["--config"]="config://=${current_workspace}/config/"
        ["--simConfig"]="config://=${current_workspace}/config/"
    )
    declare -A extension_mappings=(
        ["--scene"]="map|scene"
        ["--scenario"]="scenario"
        ["--config"]="xml"
        ["--simConfig"]="xml"
    )

    # Get mappings for the current option
    local file_ext="${extension_mappings[$option]}"
    local option_mappings="${prefix_mapping[$option]}"
    if [[ -z $option_mappings ]]; then
        return
    fi

    compopt -o nospace
    for mapping in $option_mappings; do
        IFS='=' read -r prefix base_dir <<< "$mapping"  # Split prefix=path pair
        if [[ ${cur} == ${prefix}* ]]; then

            # replace prefix with base directory.
            local full_path="${base_dir}${cur#${prefix}}"
            cur="$full_path"
            _filedir "$file_ext"

            # replace base directory with //
            local i=${#COMPREPLY[@]}
            while [ $((--i)) -ge 0 ]; do
                local value=${COMPREPLY[i]}
                COMPREPLY[i]="//${value#${base_dir}}"
                if [ -d "$value" ]; then
                    COMPREPLY[i]="${COMPREPLY[i]}/"
                fi
            done
            return # Return on first match
        fi
    done

    # Get all the supported prefixes.
    local prefixes=()
    for mapping in $option_mappings; do
        IFS='=' read -r prefix base_dir <<< "$mapping"  # Split prefix=path pair
        prefixes+=("$prefix")
    done
    _fms_filedir "$file_ext" "${prefixes[@]}"
}

# FMS command-line completion handler for both server and simulator options
_fms_completion(){
    local cur prev opts used_opts

    # Get current and previous words for completion
    _get_comp_words_by_ref -n := cur prev
    _split_longopt

    # Common options.
    opts="--help --config --scene --frequency --visualFrequency --eventFrequency --resume --reporting --printMessage --no-printMessage --printCodes --no-printCodes --printConsole --no-printConsole --debug --no-debug --visual --no-visual --clearDB --no-clearDB --killOnAnomaly --no-killOnAnomaly --printTiming --no-printTiming --printFPS"
    declare -A negating_opts=(
        ["--printMessage"]="--no-printMessage"
        ["--no-printMessage"]="--printMessage"
        ["--printCodes"]="--no-printCodes"
        ["--no-printCodes"]="--printCodes"
        ["--printConsole"]="--no-printConsole"
        ["--no-printConsole"]="--printConsole"
        ["--debug"]="--no-debug"
        ["--no-debug"]="--debug"
        ["--visual"]="--no-visual"
        ["--no-visual"]="--visual"
        ["--clearDB"]="--no-clearDB"
        ["--no-clearDB"]="--clearDB"
        ["--killOnAnomaly"]="--no-killOnAnomaly"
        ["--no-killOnAnomaly"]="--killOnAnomaly"
        ["--printTiming"]="--no-printTiming"
        ["--no-printTiming"]="--printTiming"
    )

    # Add simulator-specific options if running fmsSimulator
    if [[ ${COMP_WORDS[0]} == "./fmsSimulator" || ${COMP_WORDS[0]} == "fmsSimulator" ]]; then
        opts+=" --simConfig --scenario --wcsFrequency --wcs --simulation --no-simulation --robotCount"
        negating_opts+=(
            ["--simulation"]="--no-simulation"
            ["--no-simulation"]="--simulation"
            ["--wcs"]="--no-wcs"
            ["--no-wcs"]="--wcs"
        )
    fi

    # Remove used options.
    used_opts=$(printf "%s\n" "${COMP_WORDS[@]}" | grep '^--.' | sort | uniq)
    for opt in $used_opts; do
        opts=$(echo "$opts" | sed "s/$opt\b//g")
        local negating_opt=${negating_opts[${opt}]}
        if [[ -n ${negating_opt} ]]; then
            opts=$(echo "$opts" | sed "s/${negating_opt}\b//g")
        fi
    done

    case ${prev} in
        --help)
            ;;
        --scenario|--scene|--config|--simConfig)
            _fms_handle_path_completion "$cur" "$prev"
            ;;
        --frequency)
            COMPREPLY=(15)
            ;;
        --visualFrequency)
            COMPREPLY=(20)
            ;;
        --eventFrequency)
            COMPREPLY=(5)
            ;;
        --wcsFrequency)
            COMPREPLY=(5)
            ;;
        --robotCount)
            COMPREPLY=(1)
            ;;
        *)
            mapfile -t COMPREPLY< <(compgen -W "$opts" -- "$cur")
            ;;
    esac
}

# Bash completion for gd function
_gd_completion() {

    if { [[ ${COMP_WORDS[0]} == "gd" && ${COMP_WORDS[1]} == "workspace" && ( ${COMP_WORDS[2]} == "config" || ${COMP_WORDS[2]} == "run") && ${COMP_WORDS[3]} == "${COMP_WORDS[COMP_CWORD]}" ]]  || \
        [[ ${COMP_WORDS[0]} == "gdw" && ( ${COMP_WORDS[1]} == "config" || ${COMP_WORDS[1]} == "run"  ) &&  ${COMP_WORDS[2]} == "${COMP_WORDS[COMP_CWORD]}" ]]; } ; then
           local current_workspace=$(_fms_get_cws)
           if [[ -z "$current_workspace" ]]; then
               return;
           fi
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local scene_suffixes=()

        while IFS= read -r line; do
            [[ $line == FMS_SCENE*:* ]] || continue
            suffix=${line#FMS_SCENE}
            suffix=${suffix%%:*}
            scene_suffixes+=("$suffix")
        done < "${current_workspace}/.fmsconfig"

        mapfile -t COMPREPLY< <(compgen -W "${scene_suffixes[*]}" -- "$cur")
        return;
    fi

    # gd workspace config <name> or gdw config <name>
    if { [[ ${COMP_WORDS[0]} == "gd" && ${COMP_WORDS[1]} == "workspace" && ${COMP_WORDS[2]} == "config" && -n ${COMP_WORDS[3]} ]]  || \
         [[ ${COMP_WORDS[0]} == "gdw" && ${COMP_WORDS[1]} == "config" && -n ${COMP_WORDS[2]} ]]; } ; then

        _get_comp_words_by_ref -n := cur prev
        _split_longopt

        # Common options.
        opts="--help --config --scene --simConfig --scenario --frequency --visualFrequency --eventFrequency --resume --reporting --printMessage --no-printMessage --printCodes --no-printCodes --printConsole --no-printConsole --debug --no-debug --visual --no-visual --clearDB --no-clearDB --killOnAnomaly --no-killOnAnomaly --printTiming --no-printTiming --printFPS"
        declare -A negating_opts=(
            ["--printMessage"]="--no-printMessage"
            ["--no-printMessage"]="--printMessage"
            ["--printCodes"]="--no-printCodes"
            ["--no-printCodes"]="--printCodes"
            ["--printConsole"]="--no-printConsole"
            ["--no-printConsole"]="--printConsole"
            ["--debug"]="--no-debug"
            ["--no-debug"]="--debug"
            ["--visual"]="--no-visual"
            ["--no-visual"]="--visual"
            ["--clearDB"]="--no-clearDB"
            ["--no-clearDB"]="--clearDB"
            ["--killOnAnomaly"]="--no-killOnAnomaly"
            ["--no-killOnAnomaly"]="--killOnAnomaly"
            ["--printTiming"]="--no-printTiming"
            ["--no-printTiming"]="--printTiming"
        )
        # Remove used options.
        used_opts=$(printf "%s\n" "${COMP_WORDS[@]}" | grep '^--.' | sort | uniq)
        for opt in $used_opts; do
            opts=$(echo "$opts" | sed "s/$opt\b//g")
            local negating_opt=${negating_opts[${opt}]}
            if [[ -n ${negating_opt} ]]; then
                opts=$(echo "$opts" | sed "s/${negating_opt}\b//g")
            fi
        done

        case ${prev} in
            --scenario|--scene|--config|--simConfig)
                _fms_handle_path_completion "$cur" "$prev"
                ;;
            --frequency)
                COMPREPLY=(15)
                ;;
            --visualFrequency)
                COMPREPLY=(20)
                ;;
            --eventFrequency)
                COMPREPLY=(5)
                ;;
            *)
                mapfile -t COMPREPLY< <(compgen -W "$opts" -- "$cur")
                ;;
        esac
        return
    fi

    local cur prev opts pprev
    cmd="${COMP_WORDS[0]}"
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    pprev="${COMP_WORDS[COMP_CWORD-2]}"

    # Top-level options for gd
    opts=" build edit kill log sync workspace"

    case "$prev" in
        gd)
            mapfile -t COMPREPLY< <(compgen -W "$opts" -- "$cur")
            ;;
        kill|gdk)
            mapfile -t COMPREPLY< <(compgen -W "all clear py server sim" -- "$cur")
            ;;
        sync)
            mapfile -t COMPREPLY< <(compgen -d -- "$cur")
            ;;
        log)
            _gdl_completion
            ;;
        workspace)
            _gdw_completion
            ;;
        *)
            COMPREPLY=()
            ;;
    esac

    if [[ "$cmd" == "gdw" || "$pprev" == "workspace" ]]; then
            _gdw_completion
    fi

    if [[ "$cmd" == "gdl" || "$pprev" == "log" || "$cmd" == "gdlcat" || "$cmd" == "gdlget" || "$cmd" == "gdltail" ]]; then
            _gdl_completion
    fi
}

_gdw_completion() {
    local cur prev pprev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    pprev="${COMP_WORDS[COMP_CWORD-2]}"


    local cd_opts
    cd_opts="-b --build -l --logs -s --src -c --config -p --py -C --pyConfig --pyconfig -a --assets --asset"
    case "$prev" in
        gdw|workspace)
            mapfile -t COMPREPLY< <(compgen -W "cd config clear init ls run" -- "$cur")
            ;;
        *)
            COMPREPLY=()
            ;;
    esac

    case "$pprev" in
        gdw|workspace)
            case "$prev" in
                cd)
                    mapfile -t COMPREPLY< <(compgen -W "$cd_opts" -- "$cur")
                ;;
                init)
                    mapfile -t COMPREPLY< <(compgen -W "--name" -- "$cur")
                ;;
                clear)
                    mapfile -t COMPREPLY< <(compgen -W "--all -l --logs --db -d -b --build" -- "$cur")
                ;;
                ls)
                    mapfile -t COMPREPLY< <(compgen -W "$cd_opts" -- "$cur")
                ;;
            *)
                COMPREPLY=()
            esac
        ;;
    esac

}

_gdl_completion()
{
    local cur prev pprev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    pprev="${COMP_WORDS[COMP_CWORD-2]}"

    case "$prev" in
        gdltail|gdlcat|gdlget)
            mapfile -t COMPREPLY< <(compgen -W "agent fms robot wcs" -- "$cur")
            ;;
        gdl|log)
            mapfile -t COMPREPLY< <(compgen -W "cat get tail" -- "$cur")
            ;;
    esac

    case "$pprev" in
        gdl|log)
            case "$prev" in
                tail|cat|get)
                mapfile -t COMPREPLY< <(compgen -W "agent fms robot wcs" -- "$cur")
                ;;
            esac
        ;;
    esac
}


# Register the completion function for gd
complete -F _gd_completion gd
complete -F _gd_completion gdl
complete -F _gd_completion gdltail
complete -F _gd_completion gdlcat
complete -F _gd_completion gdlget
complete -F _gd_completion gdw
complete -F _gd_completion gdk

complete -F _fms_completion ./fmsServer
complete -F _fms_completion ./fmsSimulator
complete -F _fms_completion ./rmsServer
