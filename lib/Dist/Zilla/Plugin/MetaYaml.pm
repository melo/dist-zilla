package Dist::Zilla::Plugin::MetaYaml;
# ABSTRACT: produce a META.yml
use Moose;
use Moose::Autobox;
with 'Dist::Zilla::Role::FileGatherer';

use Hash::Merge::Simple ();

=head1 DESCRIPTION

This plugin will add a F<META.yml> file to the distribution.

For more information on this file, see L<Module::Build::API> and
L<http://module-build.sourceforge.net/META-spec-v1.3.html>.

=cut

sub gather_files {
  my ($self, $arg) = @_;

  require Dist::Zilla::File::InMemory;
  require YAML::XS;

  my $meta = {
    name     => $self->zilla->name,
    version  => $self->zilla->version,
    abstract => $self->zilla->abstract,
    author   => $self->zilla->authors,
    license  => $self->zilla->license->meta_yml_name,
    requires => $self->zilla->prereq,
    generated_by => (ref $self) . ' version ' . $self->VERSION,
  };

  $meta = Hash::Merge::Simple::merge($meta, $_->metadata)
    for $self->zilla->plugins_with(-MetaProvider)->flatten;

  # Flatten lists with a single element
  # workaround for simplistic Parse::CPAN::Meta YAML parser
  # used by Test::CPAN::Meta used by Plugin::MetaTests
  # We limit this to the authors entry for now, although a general
  # solution could be used
  # 
  #   while (my ($key, $value) = each %$meta) {
  #     if (ref($value) eq 'ARRAY' && @$value == 1) {
  #       $meta->{$key} = $value->[0];
  #     }
  #   }
  if (exists $meta->{author}
      && ref($meta->{author}) eq 'ARRAY'
      && @{$meta->{author}} == 1) {
    $meta->{author} = $meta->{author}[0];
  }

  my $file = Dist::Zilla::File::InMemory->new({
    name    => 'META.yml',
    content => YAML::XS::Dump($meta),
  });

  $self->add_file($file);
  return;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
