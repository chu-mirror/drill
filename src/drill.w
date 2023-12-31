@** Concept. 

Programmers often find themselves sifting through API references and library manuals
for even minor tasks like customizing output appearance. The similar situation happens
over and over again in a programmer's career, while they grasp the desired
outcome, translating that knowledge into code can usually be a challenge. A major
difference between a newbie programmer and a senior is the fluency in doing this
translating. This project tackles this hurdle by offering targeted practice exercises,
and ease the effort unnecessary for doing exercises as much as possible.

A particular object that programmers want to achieve can be acquired by a session of
interaction between programmer and computer. Let's call such session {\it operation},
then the easing is based on the assumption that
the whole operation can be replaced by a sequence of more basic operations. Most
of these basic operations are easy to complish, so we only need to pick up the hard one
and that's what we want to practice. The main purpose of this project is to automize
the trivial operations like opening a file, preparing some sample data, etc, to save time 
on practicing, plus some management and sharing of exercises.

To distinguish the exercises here, the author call them {\it drills}, so comes the name for
this project, {\tt drill}.
This project is based on the text-based interface of Unix-like systems, it's hard to do the
same thing in a graphical user interface(maybe except Emacs). Moreover, users
are supposed to be familiar with {\tt tmux} and {\tt vi}, optionally {\tt nix}.

@* Execution. Unlike other stateless command line tools, {\tt drill} has a per user state,
the command line
arguments it accepts depend on which state it's currently in. There are two states, {\it idle} and
{\it busy}, simply indicates that whether the user is practicing.
A user can not do two drills at the same time.

The basic usage is {\tt drill do}. When idle, {\tt drill} will automatically pick an appropriate
drill for the user. The algorithm tries its best to choose the one
that the user might need to practice
at that time. You can also do one specific drill by specifying its ID, by {\tt drill do DRILL-ID}.
Every drill has its uniq ID in the local database. The database built by the author of {\tt drill}
will be distributed together with {\tt drill}. You can delete it and build your own
database, but it's appreciated to contribute your drills to this project, so other people can
share your efforts.

When doing a drill, you can invoke {\tt drill hint} to get the hint given by the designer of
the drill if there's one, or you can invoke {\tt drill ref} to see if there is some references
for this drill, etc. At last, if you finished this drill, invoke {\tt drill done} to quit
practcing, or if you didn't know how to do it, invoke {\tt drill refresh} to tell {\tt drill}
that you failed at this drill. Some drills will check whether you are correct, and feed back
the result to you.

There are some other options that can be used both in idle and busy state. See manual or following
chapters for more information. These options are called {\it sub-commands} from now on.

@d sub_command (argv[1])
@<Execute sub-command according to current state.@>=
{
    if (@<{\tt drill} is in idle.@>) {
        if (@<|sub_command| can be executed when idle.@>) {
            @<Execute |sub_command| when idle.@>@;
        } else {
            fatal_error("You are not practicing, can not use sub-command %s.", argv[1]);
        }
    } else {
        if (@<|sub_command| can be executed when busy.@>) {
            @<Execute |sub_command| when busy.@>@;
        } else {
            fatal_error("You are practing, can not use sub-command %s.", argv[1]);
        }
    }
}

@* Basic facts about drill. The meaning of drill does not seem as simple as it is described above
when it comes to build
the connection between the drills and other entities. We will build a set of basic facts to talk
about drills in this chapter.

@ The core fact: {\bf drill {\it D} is of language {\it L} and about topic {\it T}}.
If you agree with it that
all drills we want to practice are of some form of languages, then all other concepts mentioned
in this document is simply some supplement to this statement. The practicing does not differ
too much from remembering phrases when learning a second foreign language, except that this
project provides particular convenience for programming languages and Unix tool commands.
And the topic, like you can talk about today's weather in English or Chinese, you can access
database from C++ or Shell, so the drill ``Write a SQL statement to
increase the salary of employee Chu by 1000\$ in a MySQL instance and send it in a C++ program''
is of language C++ and about topic database access. You might argue that this drill
involves another language SQL. Yes, and it's something should be avoided. So the drill can be
divided to ``Write a SQL statement to increase the salary of employee Chu by 1000\$'' and
``Send a SQL statement to a MySQL instance in a C++ program''. The operation to a relational
database and the accessing to a MySQL instance is discoupled, you can definitely benefit from
these two drills when you want to complish an operation like ``Write a SQL statement to increase
some data in a MySQL instance and send it in a Perl program'' or ``Write a SQL statement to delete
a record in a MySql instance and send it in a C++ program''. They share same basic operations.
@<Functions@>=
typedef int drill_t;
typedef int drill_language_t;
typedef int drill_topic_t;
drill_language_t drill_language(drill_t dr)
{
    drill_language_t lang;
    @<Set |lang| to corresponding |dr|.@>@;
    return lang;
}

drill_topic_t drill_topic(drill_t dr)
{
    drill_topic_t tpc;
    @<Set |tpc| to corresponding |dr|.@>@;
    return tpc;
}

@
@<Set |lang| to corresponding |dr|.@>=

@
@<Set |tpc| to corresponding |dr|.@>=

@ So, concretely, what languages can we practice? As it's talked above, this project is devoted to
practicing of programming languages and Unix tool commands. It's easy to understand that how
to practice programming languages, but how can we treat Unix tool commands as languages?
Nothing need to be explained more if you are familiar with Unix philosophy,
from the view of text-based interface, any input to the program can be regarded as
some written languages.

@ The choosing of topics is somewhat arbitrary, the main purpose of adding it here is to manage
the dependency of doing drills. Let's go back to the previous example again, if you want to do
a drill of language C++ and about topic accessing database, you must need C++ compiler and
related libraries to access MySQL database. This project will automatically manage these
dependencies for you if you enabled {\tt nix}. {\bf All drills of language {\it L} and about
topic {\it T} has dependency {\it Dep}}.
@<Functions@>=
typedef int drill_dependency_t;
drill_dependency_t
language_topic_dependency(drill_language_t lang, drill_topic_t tpc)
{
    drill_dependency_t dep;
    @<Set |dep| to corresponding |lang| and |tpc|.@>@;
    return dep;
}

@
@<Set |dep| to corresponding |lang| and |tpc|.@>=

@* Algorithm for well practicing.

@** Implementation.

The overall structure of the C source file.
@c
@<Header Files@>@/
@<Global Variables@>@/
@<Function Declarations@>@/
@<Functions@>@/
int main(int argc, const char *argv[])
{
    @<Pre Processing@>@;
    @<Main Procedure@>@;
    return 0;
}

@
@<Main Procedure@>=
{
    if (@<User is asking for help.@>) {
        @<Show help information.@>@;
    } else if (@<User is asking for version information.@>) {
        @<Show version information.@>@;
    } else if (@<User is invoking a sub-command.@>) {
        @<Execute sub-command according to current state.@>@;
    } else {
        fatal_error("Unknown option, drill -h to see help.");
    }
}

@
@<User is asking for help.@>=
(
    argc == 2 &&
    (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help"))
)

@
@<Show help information.@>=
{
    printf("usage: drill [subcommand] [option]\n");
}

@
@<User is asking for version information.@>=
(
    argc == 2 &&
    (!strcmp(argv[1], "-v") || !strcmp(argv[1], "--version"))
)

@
@<Show version information.@>=
{
    printf("%s\n", PACKAGE_STRING);
}

@* Configuration. The behaviour of {\tt drill} can be customized. To support flexible
configuration, JSON format is adopt for configuration file.

@ The default place for configuration file is {\tt \~/.drill\_conf.json}, you can change
it by environment variable {\tt DRILL\_CONF}.
@d drill_conf_path (drill_conf_path_func())
@<Functions@>=
const char *drill_conf_path_func()
{
    static const char *path = NULL;
    static char default_path[_POSIX_PATH_MAX];
    if (strlen(default_path) == 0) {
        @<Initialize |default_path|.@>@;
    }
    return (path || (path = getenv("DRILL_CONF"))) ? path : default_path;
}

@
@<Initialize |default_path|.@>=
{
    assert(getenv("HOME"));
    if (strlen(getenv("HOME")) + strlen("/.drill_conf.json") > _POSIX_PATH_MAX) {
        fatal_error("Your $HOME are too long.");
    }
    strcat(default_path, getenv("HOME"));
    strcat(default_path, "/.drill_conf.json");
}

@ The configuration is stored in a |struct json_object|, and the interface is not abstracted.
For convenience, an assumption on the structure of that |struct json_object| is given
and we add a way to define default values.
@<Functions@>=
struct json_object *drill_get_conf(const char *key)
{
    static struct json_object *root; /* root = { "default" : { ... }, "custom" : { ... } }*/
    struct json_object *value, *def, *cus;

    if (!root) root = json_object_new_object();

    if (key == NULL) {
        return root; /* expose hiden |root| */
    }
    assert(json_object_object_get_ex(root, "default", &def));
    assert(json_object_object_get_ex(root, "custom", &cus));
    if (json_object_object_get_ex(cus, key, &value))
        return value;
    assert(json_object_object_get_ex(def, key, &value));
    return value;
}

@ Modules register the default settings by calling this function.
@<Functions@>=
void drill_register_default(const char *key, struct json_object *val)
{
    struct json_object *root, *defaults;
    root = drill_get_conf(NULL);
    assert(json_object_object_get_ex(root, "default", &defaults));
    assert(json_object_object_add(root, key, val) == 0);
}

@ Initialize |root|.
@<Pre Processing@>=
{
    struct json_object *root = drill_get_conf(NULL);
    assert(json_object_object_add(root, "default", json_object_new_object()) == 0);
    @<Read configuration file to initialize |root|.@>@;
}

@
@<Read configuration file to initialize |root|.@>=
{
    FILE *fp;

    fp = fopen(drill_conf_path, "r");
    if (!fp) {
        warning("Can not access configuration file at %s, using default settings.",
            drill_conf_path);
        perror("additional info");
    } else {
        struct json_tokener *tok;
        struct json_object *obj;
        char *fc; /* file contents */
        @<Open configuration file and read it into |fc|.@>@;
        tok = json_tokener_new();
        obj = json_tokener_parse_ex(tok, fc, -1);
        if (!obj) {
            warning("Failed to parse configuration file at %s, using default settings.",
                drill_conf_path);
        }
        assert(json_object_object_add(root, "custom", obj) == 0);
        json_tokener_free(tok);
        fclose(fp);
        free(fc);
    }
}

@
@<Open configuration file and read it into |fc|.@>=
{
#define CONF_FILE_MAX_SIZE (1<<20) /* 1MB, I hope that it works most of the time */
    char *p, c; 
    fc = (char *) malloc(CONF_FILE_MAX_SIZE+1);
    p = fc;
    while ((c = fgetc(fp)) != EOF && (p-fc) != CONF_FILE_MAX_SIZE) *(p++) = c;
    if (p-fc == CONF_FILE_MAX_SIZE && c) {
        fatal_error("configuration file too big %s", drill_conf_path);
    }
    *p = '\0';
#undef CONF_FILE_MAX_SIZE
}

@* State saving. There are several ways to keep state between two invokations of command,
like write current state to a file and read it back in next invokaction or run a
background process to manage state among several invokations.
{\tt drill} adopts the simplest method, write the state to a file and read it back.
The introducing of state in chapter {\sl Execution} is not very accurate, there are
in fact more than two states, we can express them as ``the user is not currently
doing drill'' and ``the user is currently doing drill {\it D}''. The {\it D} can
be any drill in the database, so we have totally number of drills plus 1 states.
And by using filesystem, we can map these states to ``there isn't a file named {\tt
/tmp/drill\_state}'' and ``there is a file named {\tt /tmp/drill\_state} and the file contains
the id of the drill that the user is doing''.

@d drill_current_id drill_current_id_func()
@d state_file "/tmp/drill_state"
@<Functions@>=
int drill_current_id_func()
{
    static int id; /* the drill id is suppossed to be saved as an |int| */
    FILE *fp;

    if (id) return id;

    if (fp = fopen(state_file, "r")) {
        if (fread(&id, sizeof(int), 1, fp) != 1) {
            fatal_error("State file %s is broken, delete it and restart.", state_file);
        }
        fclose(fp);
        return id;
    }
    return 0;
}

@ And we need a function to modify current state.
@<Functions@>=
void drill_toggle_state(int id)
{
    if (drill_current_id) {
        assert(!remove(state_file));
    } else {
        FILE *fp;
        if (fp = fopen(state_file, "w")) {
            if (fwrite(&id, sizeof(int), 1, fp) != 1) {
                fatal_error("Can not create state file %s", state_file);
            }
            fclose(fp);
        } else {
            fatal_error("Can not create state file %s", state_file);
            perror("additional info");
        }
    }
}

@* Database.

@
@<Pre Processing@>=
{
    drill_register_default("User Name", json_object_new_string("Anonymous"));
}

@* Sub-commands. This section and the following ones are the major part of the
whole project. We must build
a framework carefully to manage the extensibility. Let's start from the unsolved parts
in |@<Execute sub-command according to current state.@>|.

@ It's easy to tell whether {\tt drill} is busy or not now.
@<{\tt drill} is in idle.@>=
(
    !drill_current_id
)

@ For |@<|sub_command| can be executed when idle.@>| and
|@<|sub_command| can be executed when busy.@>|, we can add more meaning to them once
we introduced the sub-command.

@ Some sub-commands might be able to executed in both state.
@<|sub_command| can be executed when idle or busy.@>= 0

@ Initialize others.
@<|sub_command| can be executed when idle.@>=
@<|sub_command| can be executed when idle or busy.@>

@ Same.
@<|sub_command| can be executed when busy.@>=
@<|sub_command| can be executed when idle or busy.@>


@ We can have a suprise by combining them, for all sub-commands can either be executed
when idle or busy.
@<User is invoking a sub-command.@>=
(
    argc > 1 &&
    ((@<|sub_command| can be executed when idle.@>) ||
        (@<|sub_command| can be executed when busy.@>))
)

@ Same technique can be applied to the execution of sub-commands.
@<Execute |sub_command| when idle.@>=
{
    if (0) {}
    @<Execute |sub_command| when idle appropriately.@>@;
    else {}
}

@
@<Execute |sub_command| when busy.@>=
{
    if (0) {}
    @<Execute |sub_command| when busy appropriately.@>@;
    else {}
}

@* Sub-command {\tt show}.
This sub-command queries {\tt drill} for informations user might want to know. Which information
you can query depends on which state {\tt drill} is currently in.

@ Anyway, it can be executed both when idle and busy.
@<|sub_command| can be executed when idle or busy.@>= || (!strcmp(sub_command, "show"))

@
@d show_info (argv[2])
@<Execute |sub_command| when idle appropriately.@>=
else if (!strcmp(sub_command, "show")) {
    if (argc != 3) {
        fatal_error("Please specify which you want to show.");
    }
    @<Show |show_info| available when idle.@>@;
    else {
        fatal_error("Information %s is not available now.", show_info);
    }
}

@
@<Show |show_info| available when idle.@>=
else if (!strcmp(show_info, "user-name")) {
    printf("%s\n", json_object_get_string(drill_get_conf("User Name")));
}

@
@<Execute |sub_command| when busy appropriately.@>=
else if (!strcmp(sub_command, "show")) {
    if (argc != 3) {
        fatal_error("Please specify which you want to show.");
    }
    @<Show |show_info| available when busy.@>@;
    else {
        fatal_error("Information %s is not available.", show_info);
    }
}

@
@<Show |show_info| available when busy.@>=
@<Show |show_info| available when idle.@>

@* Error handling.

@
@<Functions@>=
void fatal_error(const char *restrict fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    exit(1);
}

@
@<Functions@>=
void warning(const char *restrict fmt,  ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
}

@* Programming Environment.

@
@<Function Declarations@>=

const char *drill_conf_path_func(void);
struct json_object *drill_get_conf(const char *key);
void drill_register_default(const char *key, struct json_object *val);

int drill_current_id_func(void);
void drill_toggle_state(int id);

void fatal_error(const char *restrict fmt, ...);
void warning(const char *restrict fmt, ...);

@
@<Header Files@>=
#include "config.h"

#include <assert.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <json_object.h>
#include <json_tokener.h>

@
@<Global Variables@>=


