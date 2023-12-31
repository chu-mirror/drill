`#'!DRILL_PERL_BIN -w
use utf8;
use v5.34;
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
      die "You are already in doing a drill\n";
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
        &do($todo);
        $_ = &doing($_);
      }
    }
  }
} elsif ($command eq "done") {
  foreach (@drills) { $_ = &done($_) }
} elsif ($command eq "hint") {
  foreach (@drills) {
    if (&is_doing($_)) {
      my ($topic, $content, $level, $date) = &parse_drill($_);
      my ($des, $hint, $ref, $context) = &parse_content($content);
      if ($hint) {
        say $hint;
      } else {
        say "There's no hint for this drill";
      }
    }
  }
} elsif ($command eq "refresh") {
  foreach (@drills) {
    if (&is_doing($_)) {
      my ($topic, $content, $level, $date) = &parse_drill($_);
      $_ = init("$topic|$content");
    }
  }
} elsif ($command eq "stat") {
  my ($new, $old) = (0, 0);
  foreach (@drills) {
    my ($topic, $content, $level, $date) = &parse_drill($_);
    my $t = &parse_time($date);
    if ($t->date eq localtime->date) {
      if ($level == 0) {
        ++$new;
      } else {
        ++$old;
      }
    }
  }
  say "Newly added drills: $new";
  say "Reviewed drills: $old";
} else {
  die "Unknown command: $command\n";
}

foreach (@drills) {
  my ($topic, $content, $level, $date) = &parse_drill($_);
  my ($des, $hint, $ref, $context) = &parse_content($content);
  say NEWDRILLS "$topic|";
  printf NEWDRILLS "%s\n", &split_text($des, 80, "  ");
  if ($context) {
    say NEWDRILLS '  \context ', $context;
  }
  if ($ref) {
    say NEWDRILLS '  \reference ', $ref;
  }
  if ($hint) {
    say NEWDRILLS '  \hint ', $hint;
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
  if ($content =~ m/\\hint[^\\]*/) {
    $hint = "$&";
    $hint =~ s/\\\w*\s*//;
  }
  if ($content =~ m/\\reference[^\\]*/) {
    $ref = "$&";
    $ref =~ s/\\\w*\s*//;
  }
  if ($content =~ m/\\context[^\\]*/) {
    $context = "$&";
    $context =~ s/\\\w*\s*//;
    $context =~ s/\s*$//;
  }
  ($des, $hint, $ref, $context)
}

sub split_text {
  my @words = split /\s/, (shift @_);
  my ($len, $prefix) = @_;

  my $text = '';
  my $line = $prefix . (shift @words);
  foreach (@words) {
    if (length($line) + length($_) + 1 <= $len) {
      $line .= " $_";
    } else {
      $text .= "$line\n";
      $line = "$prefix$_";
    }
  }
  $text .= "$line";
  $text
}

sub parse_time {
  Time::Piece->strptime($_[0], "%a %b %d %T %Y")
}

sub do {
  my ($topic, $content, $level, $date) = &parse_drill($_[0]);
  my ($des, $hint, $ref, $context) = &parse_content($content);
  say "Topic: ${topic}";
  if ($context) {
    say "Context: ${context}";
    system("cp", "-r", "-t", ".", "${home}/context/${topic}/${context}");
  }
  printf "Description:\n%s\n",  &split_text($des, 80, "  ");
  if ($ref) {
    my @refs = split /\s*,\s*/, $ref;
    printf "Reference:\n" . ("  %s\n" x @refs), @refs;
  }
  if ($hint) {
    say "There is some hints, use 'drill hint' to show them";
  }
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

