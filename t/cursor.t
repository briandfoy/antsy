use utf8;
use Test::More;

my $class = 'Antsy';
BAIL_OUT( "Bail out! $class did not compile\n" ) unless use_ok( $class );

my $start_of_line = "\e[1G";

my %moves = (
	# NAME                   COMMAND  WHAT 0 RETURNS
	cursor_back          => [ 'D', ''             ],
	cursor_column        => [ 'G', $start_of_line ],
	cursor_down          => [ 'B', ''             ],
	cursor_forward       => [ 'C', ''             ],
	cursor_next_line     => [ 'E', $start_of_line ],
	cursor_previous_line => [ 'F', $start_of_line ],
	cursor_up            => [ 'A', ''             ],
	scroll_down          => [ 'T', ''             ],
	scroll_up            => [ 'S', ''             ],
	);

my %exportable = map { $_ => 1 } @Antsy::EXPORT_OK;

foreach my $name ( sort keys %moves ) {
	my( $command, $zero ) = $moves{$name}->@*;

	subtest $name => sub {
		my $code = $class->can( $name );
		ok( defined $code, "$name is defined" ) or return;
		ok( $exportable{$name}, "$name is in \@EXPORT_OK" );

		is( $code->(),   "\e[1$command",  "$name() defaults to 1" );
		is( $code->($_), "\e[$_$command", "$name($_)" ) for 1, 3, 12;
		is( $code->(0),  $zero,           "$name(0) never emits a count of 0" );
		is( $code->($_), $zero,           "$name('$_') counts as 0" ) for -2, 'x', 1.5;
		};
	}

done_testing();

__END__

=encoding utf8

=head1 NAME

t/cursor.t - check Antsy's counted cursor and scroll moves

=head1 SYNOPSIS

	prove -l t/cursor.t

=head1 DESCRIPTION

For each cursor and scroll function that takes a count, checks that
it's defined and exportable, that the count defaults to 1, that it
returns the right sequence for several counts, and that a count of 0
(or anything that isn't a non-negative integer) never puts a 0 in the
sequence, because terminals treat that as 1.

=head1 SOURCE AVAILABILITY

This source is in GitHub:

	https://github.com/briandfoy/antsy

=head1 AUTHOR

Claude Opus 5.5 (Anthropic), author

brian d foy, C<< <briandfoy@pobox.com> >>, supervisor

=head1 COPYRIGHT AND LICENSE

Copyright © 2026, brian d foy C<< <briandfoy@pobox.com> >>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut
