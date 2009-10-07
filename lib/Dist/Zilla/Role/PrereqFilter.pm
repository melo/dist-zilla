package Dist::Zilla::Role::PrereqFilter;
# ABSTRACT: hook to filter discovered prereqs
use Moose::Role;

=head1 DESCRIPTION

PrereqFilter plugins have a C<filter_prereqs> method that receives a
hashref with all the discovered required packages. It should modify the
hash in-place, adding, removing or modifying the required version.

=cut

with 'Dist::Zilla::Role::Plugin';
requires 'filter_prereqs';

no Moose::Role;
1;
