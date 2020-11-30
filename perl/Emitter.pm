# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

package Emitter;

use PDL;

sub new {
	my ($class, $position) = @_;
	$position = zeroes(3)
		if not defined($position);
	my $self = {
		position => $position,
	};
	return bless $self, $class;
}

sub emit {
	my $self = shift;
	my $pos = $self->{position}->copy;
	$pos->index(0) += int(rand(70));
	return new Particle(
		$pos,
		pdl [0, 1, 0]
	);
}

1;
