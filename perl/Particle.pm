# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

package Particle;

use PDL::Core;

sub new {
	my $class = shift;
	my $position = shift;
	$position = zeroes(3) if not defined($position);
	my $velocity = shift;
	$velocity = zeroes(3) if not defined($velocity);

	my $self = {
		position => $position,
		velocity => $velocity,
		acceleration => zeroes(3),
		ttl => 1.0,
		max_velocity => 1.0,
	};

	return bless $self, $class;
}

sub position {
	my $self = shift;
}

sub isDead() {
	my $self = shift;
	return not ($self->{ttl} > 0);
}

sub update {
	my $self = shift;

	$self->{velocity} += $self->{acceleration};
	if ($self->{velocity} x $self->{velocity}->transpose > $self->{max_velocity} ** 2) {
		$self->{velocity} = $self->{velocity}->norm * $self->{max_velocity}
	}
	$self->{position} += $self->{velocity};
	$self->{ttl} -= 0.01;
}

1;
