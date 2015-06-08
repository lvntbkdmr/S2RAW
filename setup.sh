# this script sets up the user environment for using the tools
# it needs to be sourced from .profile or .bash_profile in the HOME directory
# with an argument specifying the target computer architecture 
# e.g.: . $HOME/Dropbox/S2RAW/setup.sh suze_64
#
# the available architectures are:
# macosx_32, macosx_64, linux86_32, linux86_64, cygwin

# define the home directory
S2RAW_HOME=`dirname "${BASH_SOURCE[0]}"`

# define the envionment specifics
S2RAW_ARGS=( "$@" )

# adapt the home directory variable to hold an absolute path
cd "${S2RAW_HOME:-.}"; S2RAW_HOME="$PWD"; cd - >/dev/null

# update PATH to include the tool executables
PATH="$PATH:$S2RAW_HOME/bin/${S2RAW_ARGS[0]}:$S2RAW_HOME/bin:$S2RAW_HOME/bin/mrcpbg"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$S2RAW_HOME/lib:$S2RAW_HOME/bin/${S2RAW_ARGS[0]}/lib_64"

# define CQFD_DICTIONARY_PATH for recread

CQFD_DICTIONARY_PATH="$S2RAW_HOME/etc/dd/SENTINEL2"

export S2RAW_HOME CQFD_DICTIONARY_PATH LD_LIBRARY_PATH
