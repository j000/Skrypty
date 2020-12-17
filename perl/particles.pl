#!/usr/bin/env perl
# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

BEGIN {
	binmode STDOUT, ":encoding(UTF-8)";
	binmode STDERR, ":encoding(UTF-8)";
	binmode STDIN, ":encoding(UTF-8)";
}

BEGIN {
	if (@ARGV) {
		print(<<"USAGE");
Prosta animacja systemu cząsteczkowego.

System czasteczkowy to technika symulowania efektów, które nie mają
zdefiniowanych brzegów. np. ognia, dymu czy ekspozji. Opiera się
na odwzorowaniu zachowania wielu małych obiektów, zamiast symulacji całego
zjawiska.

Użycie: $0

Symulację można przerwać przez naciśnięcie klawiszy Ctrl+c.

Do działania skrypt wymaga PDL. Instalacja:
    apt install pdl
    ewnetualne: perl -MCPAN -e install PDL

Jarosław Rymut, 2020
USAGE
		exit(1);
	}
}

sub load {
	my $mod = shift;
	eval("use $mod");
	if ($@) {
		say "Modul $mod jest wymagany!";
		say "Instalacja:";
		say "  apt install pdl" if ($mod eq "PDL");
		say "  perl -MCPAN -e install $mod";
		exit 1;
	}
}
BEGIN {
	load('PDL');
}

use File::Basename;
use lib dirname (__FILE__);
use Particle;
use Scene;
use ConsoleRenderer;
use CircleEmitter;
use Force;
use LimitedForce;

my $console_width = int qx/tput cols/;
my $console_height = int qx/tput lines/;

my $renderer = new ConsoleRenderer();
my $scene = new Scene($renderer);
my $emitter = new CircleEmitter(
	pdl($console_width / 2, $console_width / 2, $console_height + 2),
	$console_width / 2
);
$scene->add_emiter($emitter);
# gravity-like
$scene->add_force(new LimitedForce(pdl(0, 0, -1.0), 1.0));
# wind
$scene->add_force(new Force(pdl[0.2, 0, 0]));

$scene->main_loop();
