# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

package Force;

use PDL;

sub new {
	my $class = shift;
	my $self = {
		direction => shift,
	};
	return bless $self, $class;
}

sub apply {
	my ($self, $dt, $position, $velocity) = @_;
	return $dt * $self->{direction}->copy;
}

1;
