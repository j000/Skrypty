# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

package ConsoleRenderer;

sub new {
	my $class = shift;
	my $self = {};

	print "\033[?25l";
	return bless $self, $class;
}

sub DESTROY {
	my $self = shift;
	print "\033[?25h\033[0m";
}

sub frame {
	my ($self, $frame) = @_;
	print "\033[2J\033[H";
}

sub done {
	my ($self, $frame) = @_;
	STDOUT->flush();
}

sub draw {
	my $self = shift;
	my $particle = shift;
	my $pos = $particle->{position};
	my $x = int($pos->index(0));
	my $y = int($pos->index(1));
	# 16..192 (36)
	# my $color = 16 + 36 * int(4 * ($particle->{ttl} / 20));
	# 255 .. 232
	my $color = int(($particle->{ttl} / 20) * 24 + 232);
	print "\033[".$y.";".$x."H\e[38;5;".$color."m*";
}

# force destructor on ctrl+c
use sigtrap qw(die INT QUIT);

1;
