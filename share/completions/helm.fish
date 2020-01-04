# helm - is a tool for managing Kubernetes charts. Charts are packages
# of pre-configured Kubernetes resources.
# See: https://github.com/kubernetes/helm

function __helm_using_command
    set -l cmd (commandline -poc)
    set -l found

    test (count $cmd) -gt (count $argv)
    or return 1

    set -e cmd[1]

    for i in $argv
        contains -- $i $cmd
        and set found $found $i
    end

    test "$argv" = "$found"
end

function __helm_seen_any_subcommand_from -a cmd
    __fish_seen_subcommand_from (__helm_subcommands $cmd | string replace -r '\t.*$' '')
end

function __helm_subcommands -a cmd
    switch $cmd
        case ''
            echo completion\t'Generate autocompletions script for the specified shell (bash or zsh)'
            echo create\t'create a new chart with the given name'
            echo dependency\t'manage a chart\'s dependencies'
            echo env\t'Helm client environment information'
            echo get\t'download extended information of a named release'
            echo help\t'Help about any command'
            echo history\t'fetch release history'
            echo install\t'install a chart'
            echo lint\t'examines a chart for possible issues'
            echo list\t'list releases'
            echo package\t'package a chart directory into a chart archive'
            echo plugin\t'install, list, or uninstall Helm plugins'
            echo pull\t'download a chart from a repository and (optionally) unpack it in local directory'
            echo push-artifactory\t'Please see https://github.com/belitre/helm-push-artifactory-plugin for usage'
            echo repo\t'add, list, remove, update, and index chart repositories'
            echo rollback\t'roll back a release to a previous revision'
            echo search\t'search for a keyword in charts'
            echo show\t'show information of a chart'
            echo status\t'displays the status of the named release'
            echo template\t'locally render templates'
            echo test\t'run tests for a release'
            echo uninstall\t'uninstall a release'
            echo upgrade\t'upgrade a release'
            echo verify\t'verify that a chart at the given path has been signed and is valid'
            echo version\t'print the client version information'
        case 'dependency' 'dep' 'dependencies'
            echo build\t'Rebuild the charts/ directory'
            echo list\t'List the dependencies for the given chart'
            echo update\t'Update charts/'
        case 'get'
            echo all\t'Download all information for a named release'
            echo hooks\t'Download all hooks for a named release'
            echo manifest\t'Download the manifest for a named release'
            echo notes\t'Download the notes for a named release'
            echo values\t'Download the values file for a named release'
        case 'repo'
            echo add\t'Add a chart repository'
            echo index\t'Generate an index file'
            echo list\t'List chart repositories'
            echo remove\t'Remove a chart repository'
            echo update\t'Update information on available charts'
        case 'plugin'
            echo install\t'install one or more Helm plugins'
            echo list\t'list installed Helm plugins'
            echo uninstall\t'uninstall one or more Helm plugins'
            echo update\t'update one or more Helm plugins'
        case 'search'
            echo hub\t'search for charts in the Helm Hub or an instance of Monocular'
            echo repo\t'search repositories for a keyword in charts'
        case 'inspect' 'show'
            echo all\t'shows all information of the chart'
            echo chart\t'shows the chart\'s definition'
            echo readme\t'shows the chart\'s README'
            echo values\t'shows the chart\'s values'
    end
end

function __helm_kube_contexts
    kubectl config get-contexts -o name 2>/dev/null
end

function __helm_kube_namespaces
    kubectl get namespaces -o name | string replace 'namespace/' ''
end

function __helm_releases
    helm ls --short 2>/dev/null
end

function __helm_release_completions
    helm ls 2>/dev/null | awk 'NR >= 2 { print $1"\tRelease of "$NF  }'
end

function __helm_release_revisions
    set -l cmd (commandline -poc)

    for pair in (helm ls | awk 'NR >= 2 { print $1" "$2 }')
        echo $pair | read -l release revision

        if contains $release $cmd
            seq 1 $revision
            return
        end
    end
end

function __helm_repositories
    helm repo list | awk 'NR >= 2 { print $1 }'
end

function __helm_charts
    helm search | awk 'NR >= 2 && !/^local\// { print $1 }'
end

function __helm_chart_versions
    set -l cmd (commandline -poc)

    for pair in (helm search -l | awk 'NR >= 2 { print $1" "$2 }')
        echo $pair | read -l chart version

        if contains $chart $cmd
            echo $version
        end
    end
end

#
# Global Flags
#
complete -c helm -l add-dir-header -d 'If true, adds the file directory to the header'
complete -c helm -l alsologtostderr -d 'log to standard error as well as files'
complete -c helm -l debug -f -d 'Enable verbose output'
complete -c helm -s h -l help -f -d 'More information about a command'
complete -c helm -l kube-context -x -a '(__helm_kube_contexts)' -d 'Name of the kubeconfig context to use'
complete -c helm -l kubeconfig -d 'path to the kubeconfig file'
complete -c helm -l log-backtrace-at -x -d 'when logging hits line file:N, emit a stack trace (default :0)'
complete -c helm -l log-dir -r -d 'If non-empty, write log files in this directory'
complete -c helm -l log-file -r -d 'If non-empty, write log files in this directory'
complete -c helm -l log-file-max-size -r -d 'Defines the maximum size a log file can grow to. Unit is megabytes. If the value is 0, the maximum file size is unlimited. (default 1800)'
complete -c helm -l logtostderr -d 'log to standard error instead of files (default true)'
complete -c helm -s n -l namespace -r -d 'log to standard error instead of files (default true)'
complete -c helm -l registry-config -r -d 'path to the registry config file (default "/home/jesus/.config/helm/registry.json")'
complete -c helm -l repository-cache -r -d 'path to the registry config file (default "/home/jesus/.config/helm/registry.json")'
complete -c helm -l repository-config -r -d 'path to the registry config file (default "/home/jesus/.config/helm/registry.json")'
complete -c helm -l skip-headers -d 'path to the registry config file (default "/home/jesus/.config/helm/registry.json")'
complete -c helm -l skip-log-headers -d 'If true, avoid headers when opening log files'
complete -c helm -l stderrthreshold -r -d 'logs at or above this threshold go to stderr (default 2)'
complete -c helm -l v -s v -r -d 'number for the log level verbosity'
complete -c helm -l vmodule -d 'comma-separated list of pattern=N settings for file-filtered logging' 
#
# Commands
#

# helm [command]
complete -c helm -n 'not __helm_seen_any_subcommand_from ""' -x -a '(__helm_subcommands "")'

# helm create NAME [flags]
complete -c helm -n '__helm_using_command create' -s p -l starter -x -d 'The name or absolute path to Helm starter scaffold'

# helm uninstall [flags] RELEASE [...]
complete -c helm -n '__helm_using_command uninstall' -f -a '(__helm_release_completions)' -d 'Release'

complete -c helm -n '__helm_using_command uninstall' -l dry-run -f -d 'Simulate a uninstall'
complete -c helm -n '__helm_using_command uninstall' -l no-hooks -f -d 'Prevent hooks from running during deletion'
complete -c helm -n '__helm_using_command uninstall' -l purge -f -d 'Remove the release from the store'
complete -c helm -n '__helm_using_command uninstall' -l keep-history -f -d 'remove all associated resources and mark the release as deleted, but retain the release history'
complete -c helm -n '__helm_using_command uninstall' -l timeout -x -d 'time to wait for any individual Kubernetes operation (like Jobs for hooks) (default 5m0s)'

complete -c helm -n '__helm_using_command delete' -f -a '(__helm_release_completions)' -d 'Release'

complete -c helm -n '__helm_using_command delete' -l dry-run -f -d 'Simulate a uninstall'
complete -c helm -n '__helm_using_command delete' -l no-hooks -f -d 'Prevent hooks from running during deletion'
complete -c helm -n '__helm_using_command delete' -l purge -f -d 'Remove the release from the store'
complete -c helm -n '__helm_using_command delete' -l keep-history -f -d 'remove all associated resources and mark the release as deleted, but retain the release history'
complete -c helm -n '__helm_using_command delete' -l timeout -x -d 'time to wait for any individual Kubernetes operation (like Jobs for hooks) (default 5m0s)'

complete -c helm -n '__helm_using_command del' -f -a '(__helm_release_completions)' -d 'Release'

complete -c helm -n '__helm_using_command del' -l dry-run -f -d 'Simulate a uninstall'
complete -c helm -n '__helm_using_command del' -l no-hooks -f -d 'Prevent hooks from running during deletion'
complete -c helm -n '__helm_using_command del' -l purge -f -d 'Remove the release from the store'
complete -c helm -n '__helm_using_command del' -l keep-history -f -d 'remove all associated resources and mark the release as deleted, but retain the release history'
complete -c helm -n '__helm_using_command del' -l timeout -x -d 'time to wait for any individual Kubernetes operation (like Jobs for hooks) (default 5m0s)'

# helm dependency [command]
complete -c helm -n '__helm_using_command dependency; and not __helm_seen_any_subcommand_from dependency' -x -a '(__helm_subcommands dependency)'

complete -c helm -n '__helm_using_command dep; and not __helm_seen_any_subcommand_from dependency' -x -a '(__helm_subcommands dependency)'

complete -c helm -n '__helm_using_command dependencies; and not __helm_seen_any_subcommand_from dependency' -x -a '(__helm_subcommands dependency)'


# helm dependency build [flags] CHART
complete -c helm -n '__helm_using_command dependency build' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command dependency build' -l verify -f -d 'Verify the packages against signatures'


complete -c helm -n '__helm_using_command dependencies build' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command dependencies build' -l verify -f -d 'Verify the packages against signatures'

complete -c helm -n '__helm_using_command dep build' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command dep build' -l verify -f -d 'Verify the packages against signatures'


# helm dependency update [flags] CHART
complete -c helm -n '__helm_using_command dependency update' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command dependency update' -l verify -f -d 'Verify the packages against signatures'
complete -c helm -n '__helm_using_command dependency update' -l skip-refresh -f -d 'do not refresh the local repository cache'

complete -c helm -n '__helm_using_command dependencies update' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command dependencies update' -l verify -f -d 'Verify the packages against signatures'
complete -c helm -n '__helm_using_command dependencies update' -l skip-refresh -f -d 'do not refresh the local repository cache'

complete -c helm -n '__helm_using_command dep update' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command dep update' -l verify -f -d 'Verify the packages against signatures'
complete -c helm -n '__helm_using_command dep update' -l skip-refresh -f -d 'do not refresh the local repository cache'

# helm fetch [flags] [chart URL | repo/chartname] [...]
complete -c helm -n '__helm_using_command fetch; and not __fish_seen_subcommand_from (__helm_charts)' -f -a '(__helm_charts)' -d 'Chart'

complete -c helm -n '__helm_using_command fetch' -l ca-file -r -d 'verify certificates of HTTPS-enabled servers using this CA bundle'
complete -c helm -n '__helm_using_command fetch' -l cert-file -r -d 'identify HTTPS client using this SSL certificate file'
complete -c helm -n '__helm_using_command fetch' -l devel -f -d 'use development versions, too. Equivalent to version '>0.0.0-0'. If --version is set, this is ignored.'
complete -c helm -n '__helm_using_command fetch' -l key-file -r -d 'identify HTTPS client using this SSL key file'
complete -c helm -n '__helm_using_command fetch' -l password -x -d 'chart repository password where to locate the requested chart'
complete -c helm -n '__helm_using_command fetch' -l prov -f -d 'fetch the provenance file, but don\'t perform verification'
complete -c helm -n '__helm_using_command fetch' -l repo -x -a (echo (helm repo list | cut -f2 | egrep "^http"))
complete -c helm -n '__helm_using_command fetch' -s d -l destination -r -d 'Location to write the chart'
complete -c helm -n '__helm_using_command fetch' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command fetch' -l prov -f -d 'Fetch the provenance file'
complete -c helm -n '__helm_using_command fetch' -l untar -f -d 'Will untar the chart after downloading it'
complete -c helm -n '__helm_using_command fetch --untar' -l untardir -r -d 'Directory into which the chart is expanded'
complete -c helm -n '__helm_using_command fetch' -l verify -f -d 'Verify the package against its signature'
complete -c helm -n '__helm_using_command fetch' -l version -x -a '(__helm_chart_versions)' -d 'Chart version'

complete -c helm -n '__helm_using_command pull; and not __fish_seen_subcommand_from (__helm_charts)' -f -a '(__helm_charts)' -d 'Chart'

complete -c helm -n '__helm_using_command pull' -l ca-file -r -d 'verify certificates of HTTPS-enabled servers using this CA bundle'
complete -c helm -n '__helm_using_command pull' -l cert-file -r -d 'identify HTTPS client using this SSL certificate file'
complete -c helm -n '__helm_using_command pull' -l devel -f -d 'use development versions, too. Equivalent to version '>0.0.0-0'. If --version is set, this is ignored.'
complete -c helm -n '__helm_using_command pull' -l key-file -r -d 'identify HTTPS client using this SSL key file'
complete -c helm -n '__helm_using_command pull' -l password -x -d 'chart repository password where to locate the requested chart'
complete -c helm -n '__helm_using_command pull' -l prov -f -d 'fetch the provenance file, but don\'t perform verification'
complete -c helm -n '__helm_using_command pull' -l repo -x -a (echo (helm repo list | cut -f2 | egrep "^http"))
complete -c helm -n '__helm_using_command pull' -s d -l destination -r -d 'Location to write the chart'
complete -c helm -n '__helm_using_command pull' -l keyring -r -d 'Keyring containing public keys'
complete -c helm -n '__helm_using_command pull' -l prov -f -d 'Fetch the provenance file'
complete -c helm -n '__helm_using_command pull' -l untar -f -d 'Will untar the chart after downloading it'
complete -c helm -n '__helm_using_command pull --untar' -l untardir -r -d 'Directory into which the chart is expanded'
complete -c helm -n '__helm_using_command pull' -l verify -f -d 'Verify the package against its signature'
complete -c helm -n '__helm_using_command pull' -l version -x -a '(__helm_chart_versions)' -d 'Chart version'


# helm get [command]
complete -c helm -n '__helm_using_command get; and not __helm_seen_any_subcommand_from get' -f -a '(__helm_subcommands get)'

# helm get values [flags] RELEASE
complete -c helm -n '__helm_using_command get values' -a '(__helm_release_completions)'
complete -c helm -n '__helm_using_command get values' -s a -l all -f -d 'Dump all (computed) values'
complete -c helm -n '__helm_using_command get values' -s o -l output -x -a 'table json yaml' -d 'prints the output in the specified format. Allowed values: table, json, yaml (default table)'
complete -c helm -n '__helm_using_command get values' -l revision -x -d 'get the named release with revision'

# helm get all [flags] RELEASE
complete -c helm -n '__helm_using_command get all' -a '(__helm_release_completions)'
complete -c helm -n '__helm_using_command get all' -l revision -x -d 'get the named release with revision'
complete -c helm -n '__helm_using_command get all' -l template -r -d 'go template for formatting the output, eg: {{.Release.Name}}'

# helm get hooks [flags] RELEASE
complete -c helm -n '__helm_using_command get hooks' -a '(__helm_release_completions)'
complete -c helm -n '__helm_using_command get hooks' -l revision -x -d 'get the named release with revision'

# helm get manifest [flags] RELEASE
complete -c helm -n '__helm_using_command get manifest' -a '(__helm_release_completions)'
complete -c helm -n '__helm_using_command get manifest' -l revision -x -d 'get the named release with revision'

# helm get notes [flags] RELEASE
complete -c helm -n '__helm_using_command get notes' -a '(__helm_release_completions)'
complete -c helm -n '__helm_using_command get notes' -l revision -x -d 'get the named release with revision'


# helm history [flags] RELEASE
complete -c helm -n '__helm_using_command history' -f -a '(__helm_release_completions)' -d 'Release'

complete -c helm -n '__helm_using_command history' -l max -x -d 'Maximum number of revision to include in history'
complete -c helm -n '__helm_using_command history' -s o -l output -x -a 'table json yaml' -d 'prints the output in the specified format. Allowed values: table, json, yaml (default table)'

complete -c helm -n '__helm_using_command hist' -f -a '(__helm_release_completions)' -d 'Release'

complete -c helm -n '__helm_using_command hist' -l max -x -d 'Maximum number of revision to include in history'
complete -c helm -n '__helm_using_command hist' -s o -l output -x -a 'table json yaml' -d 'prints the output in the specified format. Allowed values: table, json, yaml (default table)'

# helm inspect [command]
complete -c helm -n '__helm_using_command inspect; and not __helm_seen_any_subcommand_from inspect' -f -a '(__helm_subcommands inspect)'
complete -c helm -n '__helm_using_command show; and not __helm_seen_any_subcommand_from inspect' -f -a '(__helm_subcommands inspect)'

# helm inspect [CHART] [flags]
complete -c helm -n '__helm_using_command inspect' -l ca-file -r -d 'verify certificates of HTTPS-enabled servers using this CA bundle'
complete -c helm -n '__helm_using_command inspect' -l cert-file -r -d 'identify HTTPS client using this SSL certificate file'
complete -c helm -n '__helm_using_command inspect' -s h -l help -f -d 'help for all'
complete -c helm -n '__helm_using_command inspect' -l key-file -r -d 'identify HTTPS client using this SSL key file'
complete -c helm -n '__helm_using_command inspect' -l keyring -r -d 'location of public keys used for verification (default "/home/jesus/.gnupg/pubring.gpg")'
complete -c helm -n '__helm_using_command inspect' -l password -r -d 'chart repository password where to locate the requested chart'
complete -c helm -n '__helm_using_command inspect' -l repo -r -d 'chart repository url where to locate the requested chart'
complete -c helm -n '__helm_using_command inspect' -l username -r -d 'chart repository username where to locate the requested chart'
complete -c helm -n '__helm_using_command inspect' -l verify -f -d 'verify the package before installing it'
complete -c helm -n '__helm_using_command inspect' -l version -r -d 'specify the exact chart version to install. If this is not specified, the latest version is installed'

complete -c helm -n '__helm_using_command show' -l ca-file -r -d 'verify certificates of HTTPS-enabled servers using this CA bundle'
complete -c helm -n '__helm_using_command show' -l cert-file -r -d 'identify HTTPS client using this SSL certificate file'
complete -c helm -n '__helm_using_command show' -s h -l help -f -d 'help for all'
complete -c helm -n '__helm_using_command show' -l key-file -r -d 'identify HTTPS client using this SSL key file'
complete -c helm -n '__helm_using_command show' -l keyring -r -d 'location of public keys used for verification (default "/home/jesus/.gnupg/pubring.gpg")'
complete -c helm -n '__helm_using_command show' -l password -r -d 'chart repository password where to locate the requested chart'
complete -c helm -n '__helm_using_command show' -l repo -r -d 'chart repository url where to locate the requested chart'
complete -c helm -n '__helm_using_command show' -l username -r -d 'chart repository username where to locate the requested chart'
complete -c helm -n '__helm_using_command show' -l verify -f -d 'verify the package before installing it'
complete -c helm -n '__helm_using_command show' -l version -r -d 'specify the exact chart version to install. If this is not specified, the latest version is installed'

# helm install [CHART] [flags]
complete -c helm -n '__helm_using_command install; and not __fish_seen_subcommand_from (__helm_charts)' -a '(__helm_charts)' -d 'Chart'

complete -c helm -n '__helm_using_command install' -l atomic -d 'if set, installation process purges chart on fail. The --wait flag will be set automatically if --atomic is used'
complete -c helm -n '__helm_using_command install' -l ca-file -r -d 'verify certificates of HTTPS-enabled servers using this CA bundle'
complete -c helm -n '__helm_using_command install' -l cert-file -r -d 'identify HTTPS client using this SSL certificate file'
complete -c helm -n '__helm_using_command install' -l dependency-update -d 'run helm dependency update before installing the chart'
complete -c helm -n '__helm_using_command install' -l devel -d 'use development versions, too. Equivalent to version \'>0.0.0-0\'. If --version is set, this is ignored'
complete -c helm -n '__helm_using_command install' -l dry-run -d 'simulate an install'
complete -c helm -n '__helm_using_command install' -s g -l generate-name -d 'generate the name (and omit the NAME parameter)'
complete -c helm -n '__helm_using_command install' -s h, -l help -d 'help for install'
complete -c helm -n '__helm_using_command install' -l key-file -r -d 'identify HTTPS client using this SSL key file'
complete -c helm -n '__helm_using_command install' -l keyring -r -d 'location of public keys used for verification (default "/home/jesus/.gnupg/pubring.gpg")'
complete -c helm -n '__helm_using_command install' -l name-template -r -d 'specify template used to name the release'
complete -c helm -n '__helm_using_command install' -l no-hooks -d 'prevent hooks from running during install'
complete -c helm -n '__helm_using_command install' -s o -l output format -a 'table json yaml' -d 'prints the output in the specified format. Allowed values: table, json, yaml (default table)'
complete -c helm -n '__helm_using_command install' -l password -r -d 'chart repository password where to locate the requested chart'
complete -c helm -n '__helm_using_command install' -l render-subchart-notes -d 'if set, render subchart notes along with the parent'
complete -c helm -n '__helm_using_command install' -l replace -d 're-use the given name, only if that name is a deleted release which remains in the history. This is unsafe in production'
complete -c helm -n '__helm_using_command install' -l repo -r -d 'chart repository url where to locate the requested chart'
complete -c helm -n '__helm_using_command install' -l set -r -d 'set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command install' -l set-file -r -d 'set values from respective files specified via the command line (can specify multiple or separate values with commas: key1=path1,key2=path2)'
complete -c helm -n '__helm_using_command install' -l set-string -r -d 'set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command install' -l skip-crds -d 'if set, no CRDs will be installed. By default, CRDs are installed if not already present'
complete -c helm -n '__helm_using_command install' -l timeout -r -d 'time to wait for any individual Kubernetes operation (like Jobs for hooks) (default 5m0s)'
complete -c helm -n '__helm_using_command install' -l username -r -d 'chart repository username where to locate the requested chart'
complete -c helm -n '__helm_using_command install' -s f -l values -r -d 'specify values in a YAML file or a URL(can specify multiple)'
complete -c helm -n '__helm_using_command install' -l verify -d 'verify the package before installing it'
complete -c helm -n '__helm_using_command install' -l version -r -d 'specify the exact chart version to install. If this is not specified, the latest version is installed'
complete -c helm -n '__helm_using_command install' -l wait -d 'if set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment, StatefulSet, or ReplicaSet are in a ready state before marking the release as successful. It will wait for as long as --timeout'

# helm lint [flags] PATH
complete -c helm -n '__helm_using_command lint' -s h -l help -d 'help for lint'
complete -c helm -n '__helm_using_command lint' -l set -r -d 'set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command lint' -l set-file -r -d 'set values from respective files specified via the command line (can specify multiple or separate values with commas: key1=path1,key2=path2)'
complete -c helm -n '__helm_using_command lint' -l set-string -r -d 'set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command lint' -l strict -d 'fail on lint warnings'
complete -c helm -n '__helm_using_command lint' -s f -l values -r -d 'specify values in a YAML file or a URL(can specify multiple)'

# helm list [flags] [FILTER]
complete -c helm -n '__helm_using_command list' -s a -l all -d ' show all releases, not just the ones marked deployed or failed'
complete -c helm -n '__helm_using_command list' -l all-namespaces -d 'ist releases across all namespaces'
complete -c helm -n '__helm_using_command list' -s d -l date -d ' sort by release date'
complete -c helm -n '__helm_using_command list' -l deployed -d 'how deployed releases. If no other is specified, this will be automatically enabled'
complete -c helm -n '__helm_using_command list' -l failed -d 'how failed releases'
complete -c helm -n '__helm_using_command list' -s f -l filter -r -d ' a regular expression (Perl compatible). Any releases that match the expression will be included in the results'
complete -c helm -n '__helm_using_command list' -s h -l help -d ' help for list'
complete -c helm -n '__helm_using_command list' -s m -l max -d ' maximum number of releases to fetch (default 256)'
complete -c helm -n '__helm_using_command list' -l offset -d 'ext release name in the list, used to offset from start value'
complete -c helm -n '__helm_using_command list' -s o -l output format -a 'table json yaml' -d ' prints the output in the specified format. Allowed values: table, json, yaml (default table)'
complete -c helm -n '__helm_using_command list' -l pending -d 'how pending releases'
complete -c helm -n '__helm_using_command list' -s r -l reverse -d ' reverse the sort order'
complete -c helm -n '__helm_using_command list' -s q -l short -d ' output short (quiet) listing format'
complete -c helm -n '__helm_using_command list' -l superseded -d 'how superseded releases'
complete -c helm -n '__helm_using_command list' -l uninstalled -d 'how uninstalled releases'
complete -c helm -n '__helm_using_command list' -l uninstalling -d 'how releases that are currently being uninstalled'

# helm package [flags] [CHART_PATH] [...]
complete -c helm -n '__helm_using_command package' -l app-version -r -d 'set the appVersion on the chart to this version'
complete -c helm -n '__helm_using_command package' -s u -l dependency-update -f -d ' update dependencies from "Chart.yaml" to dir "charts/" before packaging'
complete -c helm -n '__helm_using_command package' -s d -l destination -r -d ' location to write the chart. (default ".")'
complete -c helm -n '__helm_using_command package' -s h -l help -f -d ' help for package'
complete -c helm -n '__helm_using_command package' -l key -r -d ' name of the key to use when signing. Used if --sign is true'
complete -c helm -n '__helm_using_command package' -l keyring -r -d ' location of a public keyring (default "/home/jesus/.gnupg/pubring.gpg")'
complete -c helm -n '__helm_using_command package' -l set -r -d 'set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command package' -l set-file -r -d 'set values from respective files specified via the command line (can specify multiple or separate values with commas: key1=path1,key2=path2)'
complete -c helm -n '__helm_using_command package' -l set-string -r -d 'set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command package' -l sign -f -d 'use a PGP private key to sign this package'
complete -c helm -n '__helm_using_command package' -s f -l values -r -d 'specify values in a YAML file or a URL(can specify multiple)'
complete -c helm -n '__helm_using_command package' -l version -r -d 'set the version on the chart to this semver version'

# helm repo [command]
complete -c helm -n '__helm_using_command repo; and not __helm_seen_any_subcommand_from repo' -f -a '(__helm_subcommands repo)'

# helm repo add [flags] [NAME] [URL]
complete -c helm -n '__helm_using_command repo add' -l no-update -f -d 'Raise error if repo is already registered'

# helm repo index [flags] [DIR]
complete -c helm -n '__helm_using_command repo index' -l merge -x -d 'Merge the generated index into the given index'
complete -c helm -n '__helm_using_command repo index' -l url -x -d 'URL of chart repository'

# helm repo remove [flags] [NAME]
complete -c helm -n '__helm_using_command repo remove' -f -a '(__helm_repositories)' -d 'Repository'

# helm rollback [RELEASE] [REVISION] [flags]
complete -c helm -n '__helm_using_command rollback; and not __fish_seen_subcommand_from (__helm_releases)' -f -a '(__helm_release_completions)' -d 'Release'
complete -c helm -n '__helm_using_command rollback' -f -a '(__helm_release_revisions)' -d 'Revision'

complete -c helm -n '__helm_using_command rollback' -l dry-run -f -d 'Simulate a rollback'
complete -c helm -n '__helm_using_command rollback' -l no-hooks -f -d 'Prevent hooks from running during rollback'

# helm search [keyword] [flags]
complete -c helm -n '__helm_using_command search' -s r -l regexp -f -d 'Use regular expressions for searching'
complete -c helm -n '__helm_using_command search' -s l -l versions -f -d 'Show the long listing'

# helm serve [flags]
complete -c helm -n '__helm_using_command serve' -l address -x -d 'Address to listen on'
complete -c helm -n '__helm_using_command serve' -l repo-path -r -d 'Path from which to serve charts'

# helm status [flags] RELEASE
complete -c helm -n '__helm_using_command status' -f -a '(__helm_release_completions)' -d 'Release'

complete -c helm -n '__helm_using_command status' -l revision -x -a '(__helm_release_revisions)' -d 'Revision'

# helm upgrade [RELEASE] [CHART] [flags]
complete -c helm -n '__helm_using_command upgrade; and not __fish_seen_subcommand_from (__helm_releases)' -f -a '(__helm_release_completions)' -d 'Release'
complete -c helm -n '__helm_using_command upgrade; and __fish_seen_subcommand_from (__helm_releases); and not __fish_seen_subcommand_from (__helm_charts)' -a '(__helm_charts)' -d 'Chart'

complete -c helm -n '__helm_using_command upgrade' -l atomic -d 'if set, upgrade process rolls back changes made in case of failed upgrade. The --wait flag will be set automatically if --atomic is used' 
complete -c helm -n '__helm_using_command upgrade' -l ca-file -r -d 'verify certificates of HTTPS-enabled servers using this CA bundle' 
complete -c helm -n '__helm_using_command upgrade' -l cert-file -r -d 'identify HTTPS client using this SSL certificate file' 
complete -c helm -n '__helm_using_command upgrade' -l cleanup-on-fail -d 'allow deletion of new resources created in this upgrade when upgrade fails' 
complete -c helm -n '__helm_using_command upgrade' -l devel -d 'use development versions, too. Equivalent to version \'>0.0.0-0\'. If --version is set, this is ignored' 
complete -c helm -n '__helm_using_command upgrade' -l dry-run -d 'simulate an upgrade' 
complete -c helm -n '__helm_using_command upgrade' -l force -d 'force resource updates through a replacement strategy' 
complete -c helm -n '__helm_using_command upgrade' -s h -l help -d ' help for upgrade' 
complete -c helm -n '__helm_using_command upgrade' -l history-max -r -d 'limit the maximum number of revisions saved per release. Use 0 for no limit (default 10)'
complete -c helm -n '__helm_using_command upgrade' -s i -l install -d ' if a release by this name doesn\'t already exist, run an install' 
complete -c helm -n '__helm_using_command upgrade' -l key-file -r -d 'identify HTTPS client using this SSL key file' 
complete -c helm -n '__helm_using_command upgrade' -l keyring -r -d 'location of public keys used for verification (default "/home/jesus/.gnupg/pubring.gpg")'
complete -c helm -n '__helm_using_command upgrade' -l no-hooks -d 'disable pre/post upgrade hooks' 
complete -c helm -n '__helm_using_command upgrade' -s o -l output-format -a 'table json yaml' -d 'prints the output in the specified format. Allowed values: table, json, yaml (default table)'
complete -c helm -n '__helm_using_command upgrade' -l password -r -d 'chart repository password where to locate the requested chart' 
complete -c helm -n '__helm_using_command upgrade' -l render-subchart-notes -d 'if set, render subchart notes along with the parent' 
complete -c helm -n '__helm_using_command upgrade' -l repo -r -d 'chart repository url where to locate the requested chart' 
complete -c helm -n '__helm_using_command upgrade' -l reset-values -d 'when upgrading, reset the values to the ones built into the chart' 
complete -c helm -n '__helm_using_command upgrade' -l reuse-values -d 'when upgrading, reuse the last release\'s values and merge in any overrides from the command line via --set and -f. If \'--reset-values\' is specified, this is ignored' 
complete -c helm -n '__helm_using_command upgrade' -l set -r -d 'set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command upgrade' -l set-file -r -d 'set values from respective files specified via the command line (can specify multiple or separate values with commas: key1=path1,key2=path2)'
complete -c helm -n '__helm_using_command upgrade' -l set-string -r -d 'set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)'
complete -c helm -n '__helm_using_command upgrade' -l timeout -r -d 'time to wait for any individual Kubernetes operation (like Jobs for hooks) (default 5m0s)'
complete -c helm -n '__helm_using_command upgrade' -l username -r -d 'chart repository username where to locate the requested chart' 
complete -c helm -n '__helm_using_command upgrade' -s f -l values -r -d ' specify values in a YAML file or a URL(can specify multiple)'
complete -c helm -n '__helm_using_command upgrade' -l verify -d 'verify the package before installing it' 
complete -c helm -n '__helm_using_command upgrade' -l version -r -d 'specify the exact chart version to install. If this is not specified, the latest version is installed' 
complete -c helm -n '__helm_using_command upgrade' -l wait -d 'if set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment, StatefulSet, or ReplicaSet are in a ready state before marking the release as successful. It will wait for as long as --timeout' 

# helm verify [flags] PATH
complete -c helm -n '__helm_using_command verify' -l keyring -r -d 'Keyring containing public keys'

# helm version [flags]
complete -c helm -n '__helm_using_command version' -s c -l client -f -d 'Show the client version'
complete -c helm -n '__helm_using_command version' -s s -l server -f -d 'Show the server version'
