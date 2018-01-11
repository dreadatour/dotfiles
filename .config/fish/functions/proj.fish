function proj --description "Work on projects"
	if test (count $argv) -lt 1
		__proj_usage
		return
	end

	set -l is_help 0
	set -l is_verbose 0
	set -e command_name
	set -e project_name
	set -e label_name

	while test (count $argv) -gt 0
		switch "$argv[1]"
			case -v --verbose
				if test $is_verbose -eq 0
					set is_verbose 1
					set -e argv[1]
					continue
				end
			case -h --help
				set is_help 1
				set -e argv[1]
				continue
			case help
				if test -z "$command_name"
					set is_help 1
					set -e argv[1]
					continue
				end
			case list create info edit delete start set_dir cd stop
				if test -z "$command_name"
					set command_name $argv[1]
					set -e argv[1]
					continue
				end
		end

		if begin; test $is_help -eq 0; and test -n "$command_name"; end
			switch "$command_name"
				case create info edit delete start
					if test -z "$project_name"
						set project_name $argv[1]
						set -e argv[1]
						continue
					end
				case set_dir cd
					if test -z "$label_name"
						set label_name $argv[1]
						set -e argv[1]
						continue
					end
			end
		end

		__proj_error "Unknown argument '$argv[1]'"
		echo
		__proj_usage
		return
	end

	# help command
	if test $is_help -eq 1
		switch "$command_name"
			case list
				__proj_usage_list
			case create
				__proj_usage_create
			case info
				__proj_usage_info
			case edit
				__proj_usage_edit
			case delete
				__proj_usage_delete
			case start
				__proj_usage_start
			case set_dir
				__proj_usage_set_dir
			case cd
				__proj_usage_cd
			case stop
				__proj_usage_stop
			case '*'
				__proj_usage
		end
		return
	end

	# get project from env
	switch "$command_name"
		case create start
			if test -z "$project_name"
				__proj_error "No project name"
				return
			end
		case info edit delete
			if test -z "$project_name"
				if test -n "$WORK_PROJECT"
					set project_name $WORK_PROJECT
				else
					__proj_error "No active projects"
					return
				end
			end
		case set_dir cd stop
			if test -n "$WORK_PROJECT"
				set project_name $WORK_PROJECT
			else
				__proj_error "No active projects"
				return
			end
	end

	set -l project_path ''

	# check project name
	if test -n "$project_name"
		if test (string match -r '[^A-Za-z0-9_-]' "$project_name")
			__proj_error "Bad project name '$project_name' - only [A-Za-z0-9_-] symbols allowed"
			return
		end

		set project_path $HOME/.config/proj/projects/$project_name

		if test $command_name != "create"
			# check if project is exists
			if not test -d $project_path
				__proj_error "Project '$project_name' does not exist"
				return
			end
		end
	end

	# check project name is defined
	switch "$command_name"
		case create info edit delete start set_dir cd stop
			if test -z "$project_name"
				__proj_error "Project name is not defined"
				return
			end
			if test -z "$project_path"
				__proj_error "Project path is not defined"
				return
			end
	end

	set -l label_file ''

	# get label file
	switch "$command_name"
		case set_dir cd
			if test -z "$label_name"
				set label_file $project_path/labels/.root
			else
				if test (string match -r '[^A-Za-z0-9_-]' "$label_name")
					__proj_error "Bad label name '$label_name' - only [A-Za-z0-9_-] symbols allowed"
					return
				end
				set label_file $project_path/labels/$label_name
			end
	end

	# show list of projects
	if test "$command_name" = "list"
		echo "Projects list:"
		ls $HOME/.config/proj/projects/ | awk '{ print "  " $1 }'
		return
	end

	# create new project
	if test "$command_name" = "create"
		if test -d "$project_path"
			echo "Project '$project_name' already exists"
			set -gx WORK_PROJECT $project_name
			return
		end

		if test -e "$project_path"
			__proj_error "Can't create directory '$project_path' - file exists"
			return
		end

		mkdir -p $project_path
		mkdir $project_path/scripts
		mkdir $project_path/labels

		echo "Project '$project_name' created"
		set -gx WORK_PROJECT $project_name

		# run project editing after create
		set command_name "edit"
	end

	if test "$command_name" = "info"
		echo "Project '$project_name' info"
		echo
		echo "Project path: $project_path"

		if test -d $project_path/scripts
			if test -f "$project_path/scripts/start.fish"
				echo "Start script: $project_path/scripts/start.fish"
			end
			if test -f "$project_path/scripts/stop.fish"
				echo "Stop script:  $project_path/scripts/stop.fish"
			end
		end

		if test -d $project_path/labels
			set -l labels_count (command ls -A $project_path/labels | wc -l)
			if test $labels_count -gt 0
				echo -e "\nLabels:"
				ls -A $project_path/labels | while read label
					set -l label_title $label
					set -l label_value (command cat $project_path/labels/$label)
					if test "$label" = ".root"
						set label_title '[default]'
					end
					echo "$label_title -> $label_value"
				end
			end
		end

		return
	end

	# edit project
	if test "$command_name" = "edit"
		set -l start_script $project_path/scripts/start.fish
		if test -f "$start_script"
			__proj_confirm "Edit startup script?"
			if test $status -eq 0
				vim $start_script
			end
		else
			__proj_confirm "Create and edit startup script?"
			if test $status -eq 0
				vim $start_script
			end
		end

		set -l stop_script $project_path/scripts/stop.fish
		if test -f "$stop_script"
			__proj_confirm "Edit stop script?"
			if test $status -eq 0
				vim $stop_script
			end
		else
			__proj_confirm "Create and edit stop script?"
			if test $status -eq 0
				vim $stop_script
			end
		end

		return
	end

	# delete project
	if test "$command_name" = "delete"
		__proj_confirm "Delete project '$project_name'?"
		if test $status -ne 0
			return
		end

		__proj_confirm "Are you sure you want to delete project '$project_name'?"
		if test $status -ne 0
			return
		end

		rm -rf $project_path

		echo "Project '$project_name' deleted"

		if test "$WORK_PROJECT" = "$project_name"
			set -gxe WORK_PROJECT
		end

		return
	end

	# start work on project
	if test "$command_name" = "start"
		set -gx WORK_PROJECT $project_name

		set -l label_file $project_path/labels/.root
		if test -f "$label_file"
			cd (command cat $label_file)
		end

		set -l start_script $project_path/scripts/start.fish
		if test -f "$start_script"
			source $start_script
		end

		return
	end

	# set project root or label'ed directory
	if test "$command_name" = "set_dir"
		pwd >$label_file
		return
	end

	# change current working directory
	if test "$command_name" = "cd"
		cd (command cat $label_file)
		return
	end

	# stop work on current project
	if test "$command_name" = "stop"
		if test -f "$project_path/scripts/stop.fish"
			source $project_path/scripts/stop.fish
		end

		set -gxe WORK_PROJECT

		return
	end

	# no command or command is unknown
	if test -z "$command_name"
		__proj_error "No command"
		echo
		__proj_usage
		return
	else
		__proj_error "Unknown command '$command_name'"
		echo
		__proj_usage
		return
	end
end

function __proj_usage
	echo "usage: proj [<flags>] <command> [<args> ...]

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
	"
end

function __proj_usage_list
	echo "usage: proj [<flags>] list

Projects list.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode
"
end

function __proj_usage_create
	echo "usage: proj [<flags>] create <name>

Create new project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <name>               Project name.
"
end

function __proj_usage_info
	echo "usage: proj [<flags>] info [<name>]

Show info about project <name> or current project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  [<name>]             Project name.
"
end

function __proj_usage_edit
	echo "usage: proj [<flags>] edit [<name>]

Edit project <name> or current project scripts.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  [<name>]             Project name.
"
end

function __proj_usage_delete
	echo "
usage: proj [<flags>] delete <name>

Delete project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <name>               Project name.
"
end

function __proj_usage_start
	echo "usage: proj [<flags>] start <name>

Start work on project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <name>               Project name.
"
end

function __proj_usage_set_dir
	echo "usage: proj [<flags>] set_dir [<label>]

Set project root or label'ed directory.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <label>              Directory label.
"
end

function __proj_usage_cd
	echo "usage: proj [<flags>] cd [<label>]

Change current working directory to project root or label'ed directory.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode

Args:
  <label>              Directory label.
"
end

function __proj_usage_stop
	echo "usage: proj [<flags>] stop

Stop work on current project.

Flags:
      --help           Show context-sensitive help
  -v, --verbose        Enable verbose mode
"
end

function __proj_error -a text
	echo -ne '\033[0;31m'
	echo -n "ERROR: $text"
	echo -e '\033[0m'
end

function __proj_confirm -a text
	read -n 1 -l -P "$text [Y/n] " response
	switch $response
		case ''
			true
		case Y y
			true
		case N n
			false
		case '*'
			__proj_confirm $text
	end
end
