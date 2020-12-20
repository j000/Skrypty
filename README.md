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
```
    ESC, q: wyjście
    Enter, f: flaga
    Spacja: odsłonięcie
```

Obsługiwane argumenty:
```
    -h, --help  wyświetl tą pomoc i wyjdź
    -s INT      ustawia rozmiar planszy na INT x INT,
                najmniejszy rozmiar to 2x2, największy - zależy od rozmiaru
                terminala
    -m INT      ustawia ilość min - na planszy musi znajdować się
                przynajmniej jedna mina oraz przynajmniej jedno wolne pole
```

### Perl

Prosta animacja systemu cząsteczkowego.

System czasteczkowy to technika symulowania efektów, które nie mają
zdefiniowanych brzegów. np. ognia, dymu czy ekspozji. Opiera się
na odwzorowaniu zachowania wielu małych obiektów, zamiast symulacji całego
zjawiska.

Symulacja nie ma końca, działanie programu można przerwać przez naciśnięcie
klawiszy Ctrl+c.

Do działania skrypt wymaga PDL. Instalacja:
    `apt install pdl`
    ewnetualne: `perl -MCPAN -e install PDL`

### Python

Symulacja płynów

Symulacja płynów oparta o siatkę. Program wyświetla animację gęstości płynu
oraz prędkości w kierunku poziomym i pionowym.
https://web.archive.org/web/20190212194042if_/http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf

Program spróbuje wyświetlić okno i prowadzi symulację bez końca. Animację można
zapisać do pliku wykorzystując opcję --save.

Do działania program wymaga NumPy i MatPlotLib:
`apt-get install python3-matplotlib`
albo:
`pip install numpy`
`pip install matplotlib`

Argumenty opcjonalne:
```
  -h, --help            pokaż tę wiadomość i wyjdź
  --size N, -s N        rozmiar siatki symulacji (domyślnie 10)
  --deltat F, --dt F, -t F
                        delta t - zmiana czasu na krok symulacji (domyslnie
                        0.1)
  --diffusion F, --diff F, -d F
                        współczynnik dyfuzji (domyślnie 0.001) - odpowiada za
                        "rozlewanie" się wartości na sąsiednie komórki
  --viscosity F, --visc F, -v F
                        współczynnik lepkości cieczy (domyślnie 0.0001)
  --save [FILE]         nazwa pliku do zapisania animacji, jeśli program nie
                        ma działać w trybie interaktywnym
  --len F, -l F         czas trwania symulacji - przy zapisie do pliku
```
