`#'!DRILL_PERL_BIN -w
use utf8;
use v5.10;
use Time::Piece;
use Time::Seconds;


my $home = "DRILL_HOME";

if (@ARGV == 0) {
  exec("vi", "$home/DRILL_DRILLS");
}
open DRILLS, "<", "$home/DRILL_DRILLS";
open NEWDRILLS, ">", "/tmp/drills";


my @drills;
while (<DRILLS>) {
  chomp;
  if (/^\S/) {
    $_ =~ s/\s*$//;
    push @drills, $_;
  } else {
    $_ =~ s/\s*$//;
    $_ =~ s/^\s*/ /;
    $drills[-1] .= $_;
  }
}
foreach (@drills) { $_ = &init($_) }

my $command = shift @ARGV;

if ($command eq "do") {
  my $todo = $drills[0];
  foreach (@drills) {
    if (&is_doing($_)) {
      die "You are already in doing a drill";
    }
    if (&urgency($todo) < &urgency($_)) {
      $todo = $_;
    }
  }
  if (&urgency($todo) == 0) {
    say "You have no drill available to do."
  } else {
    foreach (@drills) {
      if ($todo eq $_) {
        &print_drill($todo);
        $_ = &doing($_);
      }
    }
  }
} elsif ($command eq "done") {
  foreach (@drills) { $_ = &done($_) }
} else {
  die "Unknown command: $command";
}

foreach (@drills) {
  my ($topic, $content, $level, $date) = &parse_drill($_);
  say NEWDRILLS "$topic|";
  my @lines = split /\n/, &fmt_content(&parse_content($content));
  foreach (@lines) {
    say NEWDRILLS "  $_";
  }
  say NEWDRILLS "  |$level|$date"
}

close DRILLS;
close NEWDRILLS;

open DRILLS, ">", "$home/DRILL_DRILLS";
open NEWDRILLS, "<", "/tmp/drills";
print DRILLS <NEWDRILLS>;

sub parse_drill {
  my ($drill) = @_;
  my @fields = split /\s*\|\s*/, $drill;
  @fields
}

sub fmt_drill {
  sprintf "%s|%s|%s|%s", @_;
}

sub parse_content {
  my $content = $_[0];
  my ($des, $hint, $ref, $context) = ('', '', '', '');
  if ($content =~ m/[^\\]*/) {
    $des = "$&";
  }
  if ($content =~ m/\\hint:[^\\]*/) {
    $hint = "$&";
  }
  if ($content =~ m/\\reference:[^\\]*/) {
    $ref = "$&";
  }
  if ($content =~ m/\\context:[^\\]*/) {
    $context = "$&";
  }
  ($des, $hint, $ref, $context)
}

sub fmt_content {
  my ($des, $hint, $ref, $context) = @_;
  my @words = split /\s/, $des;

  $des = '';
  my $line = shift @words;
  foreach (@words) {
    if (length($line) + length($_) + 1 <= 80) {
      $line .= " $_";
    } else {
      $des .= "$line\n";
      $line = "$_";
    }
  }
  $des .= "$line";
  my $content;
  foreach (($des, $hint, $ref, $context)) {
    if ($_) {
      $content .= "$_\n";
    }
  }
  $content
}

sub print_drill {
  my ($topic, $content, $level, $date) = &parse_drill($_[0]);
  printf "Topic: %s\n%s", $topic, &fmt_content(&parse_content($content));
}

sub parse_time {
  Time::Piece->strptime($_[0], "%a %b %d %T %Y")
}

sub init {
  my ($topic, $content, $level, $date) = &parse_drill($_[0]);
  if (!$level) {
    $level = 0;
  }
  if (!$date) {
    my $t = localtime;
    $date = "$t";
  }
  &fmt_drill($topic, $content, $level, $date)
}

sub is_doing {
  my ($topic, $content, $level, $date) = &parse_drill($_[0]);
  $level =~ /\d\*/
}

sub doing {
  my ($topic, $content, $level, $date) = &parse_drill($_[0]);
  &fmt_drill($topic, $content, $level.'*', $date)
}

sub done {
  my ($topic, $content, $level, $date) = &parse_drill($_[0]);
  if (&is_doing($_[0])) {
    my $t = localtime;
    $level =~ s/\*//;
    $level += 1;
    $date = "$t";
  }
  &fmt_drill($topic, $content, $level, $date)
}

sub urgency {
  my ($topic, $content, $level, $date) = &parse_drill($_[0]);

  my @durations = (3, 6, 18, 72, 360, 2160, 15120);
  foreach (@durations) { $_ *= ONE_DAY }

  my $t = &parse_time($date);
  my $diff = $t + $durations[$level] - localtime;
  if ($diff > $durations[$level]/3) {
    0
  } else {
    $durations[-1]-$diff
  }
}

