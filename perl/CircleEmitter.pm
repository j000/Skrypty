# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

package CircleEmitter;

use PDL;
use Math::Trig qw(pi);

use parent 'Emitter';

sub new {
	my ($class, $position, $radius) = @_;
	$radius = 1	if not defined($radius);
	$position = zeroes(3)
		if not defined($position);
	my $self = $class->SUPER::new($position);
	$self->{radius} = $radius;
	return bless $self, $class;
}

sub emit {
	my $self = shift;
	my $pos = $self->{position}->copy;

	my $r = rand($self->{radius});
	my $angle = rand(2 * pi());

	$pos->slice(0) += $r * cos($angle);
	$pos->slice(1) += $r * sin($angle);

	return new Particle(
		$pos
	);
}

1;
