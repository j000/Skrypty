#!/usr/bin/env perl
# Jarosław Rymut, 2020

use v5.30;
use warnings;
use utf8;

INIT {
	binmode STDOUT, ":encoding(UTF-8)";
	binmode STDERR, ":encoding(UTF-8)";
	binmode STDIN, ":encoding(UTF-8)";
}

my %missing;
BEGIN {
	push(@INC, ".");
    push(@INC, sub {
        my ($code, $mod) = @_;
		return if ($mod =~ /Encode/);
        $mod =~ s#/#::#g;
        $mod =~ s/\.pm$//;
        $missing{$mod}++;
        open(my $fh, '+>', undef);
        print {$fh} "package $mod;1;";
        seek($fh, 0, 0);
        return $fh;
    });
}
INIT {
    if (my @list = keys %missing) {
		warn "Program do dzialania wymaga następujących modułów: @list\n";
        exit 1;
    }
}

if (@ARGV) {
	print(<<"USAGE");
Docelowo ładny efekt z użyciem cząsteczek

Użycie: $0

Jarosław Rymut, 2020
USAGE
	exit(1);
}

use PDL;

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
