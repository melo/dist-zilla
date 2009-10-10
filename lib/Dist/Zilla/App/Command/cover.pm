use strict;
use warnings;
package Dist::Zilla::App::Command::cover;
# ABSTRACT: examine the test coverage of your distribution
use Dist::Zilla::App -command;

=head1 SYNOPSIS

Runs your (built) distribution test suite using the coverage tools.

    dzil cover

Otherwise identical to

    dzil build && cd $BUILT && cover -test

=cut

sub abstract { 'calculate coverage of test suite' }

sub run {
  my ($self, $opt, $arg) = @_;

  require Dist::Zilla;
  require File::chdir;
  require File::Temp;
  require Path::Class;

  my $build_root = Path::Class::dir('.build');
  $build_root->mkpath unless -d $build_root;

  my $target = Path::Class::dir( File::Temp::tempdir(DIR => $build_root) );
  $self->log("building test distribution under $target");

  local $ENV{AUTHOR_TESTING} = 1;
  local $ENV{RELEASE_TESTING} = 1;

  $self->zilla->ensure_built_in($target);

  eval {
    ## no critic Punctuation
    local $File::chdir::CWD = $target;
    system($^X => 'Makefile.PL') and die "error with Makefile.PL\n";
    system('make') and die "error running make\n";
    system('cover', '-test') and die "error running cover -test\n";
  };

  if ($@) {
    $self->log($@);
    $self->log("left failed dist in place at $target");
  } else {
    system('rsync', '-a', '--delete', $target->subdir('cover_db')->stringify, '.');
    $self->log("all's well; removing $target");
    $target->rmtree;
  }
  
  if (@$arg && $arg->[0] && $arg->[0] eq '-o') {
    system('open', Path::Class::dir('cover_db')->file('coverage.html')->stringify);
  }
}

1;
