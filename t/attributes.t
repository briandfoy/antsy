use utf8;
use Test::More;

my $class = 'Antsy';
BAIL_OUT( "Bail out! $class did not compile\n" ) unless use_ok( $class );

my %attributes = (
	# NAME             SGR
	reset            =>  0,
	bold             =>  1,
	dark             =>  2,
	italic           =>  3,
	underline        =>  4,
	blink            =>  5,
	reverse          =>  7,
	conceal          =>  8,
	normal_intensity => 22,
	no_bold          => 22,
	no_dark          => 22,
	no_italic        => 23,
	no_underline     => 24,
	no_blink         => 25,
	no_reverse       => 27,
	reveal           => 28,
	text_default     => 39,
	bg_default       => 49,
	);

my %exportable = map { $_ => 1 } @Antsy::EXPORT_OK;

foreach my $name ( sort keys %attributes ) {
	subtest $name => sub {
		my $code = $class->can( $name );
		ok( defined $code, "$name is defined" ) or return;
		ok( $exportable{$name}, "$name is in \@EXPORT_OK" );
		is( $code->(), "\e[$attributes{$name}m", "$name is SGR $attributes{$name}" );
		};
	}

done_testing();

__END__

=encoding utf8

=head1 NAME

t/attributes.t - check Antsy's text attribute functions

=head1 SYNOPSIS

	prove -l t/attributes.t

=head1 DESCRIPTION

Checks that each function that turns a text attribute on or off (such
as C<bold>, C<no_italic>, C<reveal>, and C<text_default>) is defined, is
in C<@EXPORT_OK>, and returns the right SGR sequence.

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
