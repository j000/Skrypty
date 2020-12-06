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
Docelowo prosta animacja zachowania cząsteczek.

Użycie: $0

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
use Emitter;
use Force;

my $renderer = new ConsoleRenderer();
my $scene = new Scene($renderer);
my $emitter = new Emitter(pdl[0, 1, 0]);
$scene->add_emiter($emitter);
my $gravity = new Force(pdl[0, 0.1, 0]);
$scene->add_force($gravity);
# wind
# $scene->add_force(new Force(pdl[0.05, 0, 0]));

$scene->main_loop();
