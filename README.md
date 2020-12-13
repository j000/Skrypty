# Jarosław Rymut

## Skrypty

### Bash

Saper

Gra polega na odkrywaniu na planszy poszczególnych pól w taki sposób,
aby nie natrafić na minę. Na każdym z odkrytych pól napisana jest liczba min,
które bezpośrednio stykają się z danym polem (od zera do ośmiu). Jeśli
oznaczymy dane pole flagą, jest ono zabezpieczone przed odsłonięciem,
dzięki czemu przez przypadek nie odsłonimy miny. Gra kończy się po okryciu
pola z miną bądź po okryciu wszystkich pól bez min.

Obsługa:  
  ESC, q: wyjście  
  Enter, f: flaga  
  Spacja: odsłonięcie  

```
Obsługiwane argumenty:  
  -h, --help      wyświetl tą pomoc i wyjdź  
  -s INT          ustawia rozmiar planszy  
  -m INT          ustawia ilość min  
```

### Perl

Prosta animacja systemu cząsteczkowego.

System czasteczkowy to technika symulowania efektów, które nie mają
zdefiniowanych brzegów. np. ognia, dymu czy ekspozji. Opiera się
na odwzorowaniu zachowania wielu małych obiektów.

Użycie: ./perl/particles.pl

```
Do działania skrypt wymaga PDL. Instalacja:  
  apt install pdl  
  ewnetualne: perl -MCPAN -e install PDL  
```

### Python

Symulacja płynów

Symulacja płynów oparta o siatkę. Program wyświetla animację gęstości płynu.
https://web.archive.org/web/20190212194042if_/http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf

Do działania program wymaga NumPy i MatPlotLib:  
  apt-get install python3-matplotlib  
  albo:  
  pip install numpy  
  pip install matplotlib  

```
Argumenty opcjonalne:  
  -h, --help            pokaż tę wiadomość i wyjdź  
  --size N, -s N        rozmiar siatki symulacji  
  --deltat F, --dt F, -t F  
                        delta t - zmiana czasu na krok symulacji  
  --diffusion F, --diff F, -d F  
                        współczynnik dyfuzji  
  --viscosity F, --visc F, -v F  
                        współczynnik lepkości cieczy  
```
