package DBIx::ParseException;
BEGIN {
  $DBIx::ParseException::VERSION = '0.001000_03';
}

use strict;
use warnings;
use DBI;
use Carp 'croak';

sub _get_driver {
  return do {
      if (my $dbh = $_[1]->{dbh}) {
      $dbh->{Driver}{Name};
    } else {
      ( DBI->parse_dsn($_[1]->{dsn}) )[1];
    }
  }
}

DRIVERS: {
   my %DRIVERS;

   sub handler {
      my $self = shift;
      my $params = shift or croak 'params are required for DBIx::ParseException!';
      my $driver = $self->_get_driver($params);
      return $DRIVERS{$driver} ||= do {
         my $parser = __PACKAGE__ . "::$driver";
         eval "require $parser";
         die $@ if $@;
         $parser->can('error_handler');
      };
   }
}

CAPABILITIES: {
   my %CAPABILITIES;

   sub capabilities {
      my $self = shift;
      my $params = shift or croak 'params are required for DBIx::ParseException!';
      my $driver = $self->_get_driver($params);
      return $CAPABILITIES{$driver} ||= do {
         my $parser = __PACKAGE__ . "::$driver";
         eval "require $parser";
         die $@ if $@;
         $parser->can('capabilities')->($parser);
      };
   }
}

1;

# vim: ts=2 tw=2 expandtab

__END__
=pod

=head1 NAME

DBIx::ParseException

=head1 VERSION

version 0.001000_03

=head1 AUTHOR

Arthur Axel "fREW" Schmidt <frioux+cpan@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Arthur Axel "fREW" Schmidt.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

