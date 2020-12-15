# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

package LimitedForce;

use parent 'Force';

use PDL;

sub new {
	my $class = shift;
	my $direction = shift;
	my $self = $class->SUPER::new($direction);
	$self->{limit} = shift;
	return bless $self, $class;
}

sub apply {
	my ($self, $dt, $position, $velocity) = @_;
	return 0 if $velocity x $velocity->transpose > $self->{limit};
	return $dt * $self->{direction}->copy;
}

1;
