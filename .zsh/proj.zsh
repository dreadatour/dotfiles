#!/bin/bash
#
# Work on projects
# ================
#
# TODO: Add config for projects home directory
# TODO: ZSH completions
# TODO: Think about command name, 'proj' is not good enough
# TODO: Find more suitable names for commands
# TODO: Respect '--verbose' flag

function __proj_usage {
	cat <<EOF
usage: proj [<flags>] <command> [<args> ...]

Work on projects.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Commands:
  help [<command>]     Show help.

  list                 Projects list.

  create <name>        Create new project.

  info [<name>]        Show project info.

  edit [<name>]        Edit project.

  delete [<name>]      Delete project.

  start <name>         Start work on project.

  set_dir [<label>]    Set project root or label'ed directory.

  cd [<label>]         Change current working directory.

  stop                 Stop work on current project.
EOF
}

function __proj_usage_list {
	cat <<EOF
usage: proj [<flags>] list

Projects list.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode
EOF
}

function __proj_usage_create {
	cat <<EOF
usage: proj [<flags>] create <name>

Create new project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <name>               Project name.
EOF
}

function __proj_usage_info {
	cat <<EOF
usage: proj [<flags>] info [<name>]

Show info about project <name> or current project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  [<name>]             Project name.
EOF
}

function __proj_usage_edit {
	cat <<EOF
usage: proj [<flags>] edit [<name>]

Edit project <name> or current project scripts.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  [<name>]             Project name.
EOF
}

function __proj_usage_delete {
	cat <<EOF
usage: proj [<flags>] delete <name>

Delete project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <name>               Project name.
EOF
}

function __proj_usage_start {
	cat <<EOF
usage: proj [<flags>] start <name>

Start work on project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <name>               Project name.
EOF
}

function __proj_usage_set_dir {
	cat <<EOF
usage: proj [<flags>] set_dir [<label>]

Set project root or label'ed directory.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <label>              Directory label.
EOF
}

function __proj_usage_cd {
	cat <<EOF
usage: proj [<flags>] cd [<label>]

Change current working directory to project root or label'ed directory.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <label>              Directory label.
EOF
}

function __proj_usage_stop {
	cat <<EOF
usage: proj [<flags>] stop

Stop work on current project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode
EOF
}

function __proj_error {
	echo -ne '\033[0;31m'
	echo -n "ERROR: $1"
	echo -e '\033[0m'
}

function __proj_confirm {
	read -r "?$1 [Y/n] " response
	case "$response" in
		'')          true;;
		Y|y|Yes|yes) true;;
		N|n|No|no)   false;;
		*) __proj_confirm $1;;
	esac
}

function proj {
	if [[ $# -eq 0 ]]; then
		__proj_usage
		return
	fi

	local is_help=
	local is_verbose=
	local command_name=
	local project_name=
	local label_name=

	# parse command line arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
			-v|--verbose)
				if [[ -z $is_verbose ]]; then
					is_verbose=1
					shift
					continue
				fi
				;;
			-h|--help)
				is_help=1
				shift
				continue
				;;
			help)
				if [[ -z $command_name ]]; then
					is_help=1
					shift
					continue
				fi
				;;
			list|create|info|edit|delete|start|set_dir|cd|stop)
				if [[ -z $command_name ]]; then
					command_name=$1
					shift
					continue
				fi
				;;
		esac

		if [[ -z $is_help ]]; then
			case $command_name in
				create|info|edit|delete|start)
					if [[ -z $project_name ]]; then
						project_name=$1
						shift
						continue
					fi
					;;
				set_dir|cd)
					if [[ -z $label_name ]]; then
						label_name=$1
						shift
						continue
					fi
					;;
			esac
		fi

		__proj_error "Unknown argument '$1'"
		echo
		__proj_usage
		return
	done

	# help command
	if [[ -n $is_help ]]; then
		case $command_name in
			list)    __proj_usage_list;;
			create)  __proj_usage_create;;
			info)    __proj_usage_info;;
			edit)    __proj_usage_edit;;
			delete)  __proj_usage_delete;;
			start)   __proj_usage_start;;
			set_dir) __proj_usage_set_dir;;
			cd)      __proj_usage_cd;;
			stop)    __proj_usage_stop;;
			*)       __proj_usage;;
		esac
		return
	fi

	# get project from env
	case $command_name in
		create|start)
			if [[ -z $project_name ]]; then
				__proj_error "No project name"
				return
			fi
			;;
		info|edit|delete)
			if [[ -z $project_name ]]; then
				if [[ -n $WORK_PROJECT ]]; then
					project_name=$WORK_PROJECT
				else
					__proj_error "No active projects"
					return
				fi
			fi
			;;
		set_dir|cd|stop)
			if [[ -n $WORK_PROJECT ]]; then
				project_name=$WORK_PROJECT
			else
				__proj_error "No active projects"
				return
			fi
			;;
	esac

	local project_path=

	# check project name
	if [[ -n $project_name ]]; then
		case $project_name in
			*[^A-Za-z0-9_-]*)
				__proj_error "Bad project name '$project_name' - only [A-Za-z0-9_-] symbols allowed"
				return
			;;
		esac

		project_path=$HOME/.config/proj/projects/$project_name

		if [[ $command_name != "create" ]]; then
			# check if project is exists
			if [[ ! -d $project_path ]]; then
				__proj_error "Project '$project_name' does not exist"
				return
			fi
		fi
	fi

	# check project name is defined
	case $command_name in
		create|info|edit|delete|start|set_dir|cd|stop)
			if [[ -z $project_name ]]; then
				__proj_error "Project name is not defined"
				return
			fi
			if [[ -z $project_path ]]; then
				__proj_error "Project path is not defined"
				return
			fi
			;;
	esac

	local label_file=

	# get label file
	case $command_name in
		set_dir|cd)
			if [[ -z $label_name ]]; then
				label_file=$project_path/labels/.root
			else
				case $label_name in
					*[^A-Za-z0-9_-]*)
						__proj_error "Bad label name '$label_name' - only [A-Za-z0-9_-] symbols allowed"
						return
					;;
				esac
				label_file=$project_path/labels/$label_name
			fi
			;;
	esac

	# show list of projects
	if [[ $command_name == "list" ]]; then
		echo "Projects list:"

		ls $HOME/.config/proj/projects/ | while read project_name; do
			echo "- $project_name"
		done

		return
	fi

	# create new project
	if [[ $command_name == "create" ]]; then
		if [[ -d $project_path ]]; then
			echo "Project '$project_name' already exists"
		elif [[ -e $project_path ]]; then
			__proj_error "Can't create directory '$project_path' - file exists"
			return
		else
			mkdir -p $project_path
			mkdir $project_path/scripts
			mkdir $project_path/labels

			echo "Project '$project_name' created"

			# run project editing after create
			command_name="edit"
		fi

		export WORK_PROJECT=$project_name

		if [[ $command_name != "edit" ]]; then
			return
		fi
	fi

	if [[ $command_name == "info" ]]; then
		echo "Project '$project_name' info"
		echo
		echo "Project path: $project_path"

		if [[ -d $project_path/scripts ]]; then
			if [[ -f $project_path/scripts/start ]]; then
				echo "Start script: $project_path/scripts/start"
			fi
			if [[ -f $project_path/scripts/stop ]]; then
				echo "Stop script:  $project_path/scripts/stop"
			fi
		fi

		if [[ -d $project_path/labels ]]; then
			local labels_count=$(ls -A $project_path/labels | wc -l)
			if [[ $labels_count -gt 0 ]]; then
				echo -e "\nLabels:"
				ls -A $project_path/labels | while read label; do
					local label_title=$label
					if [[ $label == ".root" ]]; then
						label_title='[default]'
					fi
					echo "$label_title  -> $(cat $project_path/labels/$label)"
				done
			fi
		fi

		return
	fi

	# edit project
	if [[ $command_name == "edit" ]]; then
		local start_script=$project_path/scripts/start
		if [[ -f $start_script ]]; then
			__proj_confirm "Edit startup script?"
			if [[ $? -eq 0 ]]; then
				$EDITOR $start_script
			fi
		else
			__proj_confirm "Create and edit startup script?"
			if [[ $? -eq 0 ]]; then
				echo "#!/bin/bash" > $start_script
				$EDITOR $start_script
			fi
		fi

		local start_env_script=$project_path/scripts/start-env
		if [[ -f $start_env_script ]]; then
			__proj_confirm "Edit setup environment variables script?"
			if [[ $? -eq 0 ]]; then
				$EDITOR $start_env_script
			fi
		else
			__proj_confirm "Create and edit setup environment variables script?"
			if [[ $? -eq 0 ]]; then
				echo "#!/bin/bash" > $start_env_script
				$EDITOR $start_env_script
			fi
		fi

		local stop_script=$project_path/scripts/stop
		if [[ -f $stop_script ]]; then
			__proj_confirm "Edit stop script?"
			if [[ $? -eq 0 ]]; then
				$EDITOR $stop_script
			fi
		else
			__proj_confirm "Create and edit stop script?"
			if [[ $? -eq 0 ]]; then
				echo "#!/bin/bash" > $stop_script
				$EDITOR $stop_script
			fi
		fi

		local stop_env_script=$project_path/scripts/stop-env
		if [[ -f $stop_env_script ]]; then
			__proj_confirm "Edit cleanup environment variables script?"
			if [[ $? -eq 0 ]]; then
				$EDITOR $stop_env_script
			fi
		else
			__proj_confirm "Create and edit cleanup environment variables script?"
			if [[ $? -eq 0 ]]; then
				echo "#!/bin/bash" > $stop_env_script
				$EDITOR $stop_env_script
			fi
		fi

		return
	fi

	# delete project
	if [[ $command_name == "delete" ]]; then
		__proj_confirm "Delete project '$project_name'?"
		if [[ $? -eq 0 ]]; then
			rm -rf $project_path

			echo "Project '$project_name' deleted"

			if [[ $WORK_PROJECT == $project_name ]]; then
				unset WORK_PROJECT
			fi
		fi

		return
	fi

	# start work on project
	if [[ $command_name == "start" ]]; then
		export WORK_PROJECT=$project_name

		local label_file=$project_path/labels/.root
		if [[ -f $label_file ]]; then
			cd `cat $label_file`
		fi

		local start_env_script=$project_path/scripts/start-env
		if [[ -f $start_env_script ]]; then
			. $start_env_script
		fi

		local start_script=$project_path/scripts/start
		if [[ -f $start_script ]]; then
			source $start_script
		fi

		return
	fi

	# set project root or label'ed directory
	if [[ $command_name == "set_dir" ]]; then
		pwd >$label_file
		return
	fi

	# change current working directory
	if [[ $command_name == "cd" ]]; then
		cd `cat $label_file`
		return
	fi

	# stop work on current project
	if [[ $command_name == "stop" ]]; then
		if [[ -f $project_path/scripts/stop-env ]]; then
			. $project_path/scripts/stop-env
		fi

		if [[ -f $project_path/scripts/stop ]]; then
			source $project_path/scripts/stop
		fi

		unset WORK_PROJECT

		return
	fi

	# no command or command is unknown
	if [[ -z $command_name ]]; then
		__proj_error "No command"
		echo
		__proj_usage
		return
	else
		__proj_error "Unknown command '$command_name'"
		echo
		__proj_usage
		return
	fi
}
