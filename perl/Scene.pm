# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

require Carp;
use Time::HiRes qw/usleep/;

package Scene;

sub new {
	my $class = shift;
	my $renderer = shift;
	Carp::confess("Not a renderer")
		if not $renderer->can("frame")
			or not $renderer->can("draw");
	return bless {
		renderer => $renderer,
		particles => [],
		emiters => [],
		forces => [],
		frame_time => 100,
	}, $class;
}

use overload q/""/ => sub {
	my $self = shift;
	return "Scene: renderer: $self->{renderer}";
};

sub add_emiter {
	my $self = shift;
	my $emiter = shift;
	Carp::confess("Not an emitter: $emiter") if not $emiter->can("emit");
	push @{$self->{emiters}}, $emiter;
}

sub add_force {
	my $self = shift;
	my $force = shift;
	Carp::confess("Not a force: $force") if not $force->can("apply");
	push @{$self->{forces}}, $force;
}

sub main_loop {
	my $self = shift;
	my $renderer = $self->{renderer};
	my $i = 0;
	while (1) {
		$i++;
		$renderer->frame();

		while (my ($k, $v) = each @{$self->{particles}}) {
			for my $f (@{$self->{forces}}) {
				$v->{acceleration} += $f->apply(
					$v->{position}->copy,
					$v->{velocity}->copy
				);
			}
			$v->update($i);
			$renderer->draw($v);
			if ($v->isDead()) {
				splice(@{$self->{particles}}, $k, 1);
			}
		}

		for (@{$self->{emiters}}) {
			my @tmp = $_->emit($i);
			for (@tmp) {
				$renderer->draw($_);
			}
			push @{$self->{particles}}, @tmp;
		}
		$renderer->done($i);
		$SIG{INT} = sub { exit 0 };
		Time::HiRes::usleep(int($self->{frame_time} * 1000));
	}
}

1;
