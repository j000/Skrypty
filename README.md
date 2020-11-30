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

Obsługiwane argumenty:  
  -h, --help      wyświetl tą pomoc i wyjdź  
  -s INT          ustawia rozmiar planszy  
  -m INT          ustawia ilość min  

### Perl

Cząsteczki

Symulacja cząsteczek. Docelowo z wizualizacją poza konsolą.

Do działania wymaga PDL.

### Python

Symulacja płynu

Symulacja płynu oparta o siatkę, zgodnie z opisem:
https://web.archive.org/web/20190212194042if_/http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf

Do działania wymaga NumPy i MatPlotLib.

Obsługiwane argumenty:  
  -h, --help            pokaż tę wiadomość i wyjdź  
  --size N              rozmiar symulacji  
  --deltat F, --dt F, -t F  
                        delta t - zmiana czasu na krok symulacji  
  --diffusion F, --diff F  
                        współczynnik dyfuzji  
  --viscosity F, --visc F  
                        współczynnik dyfuzji  
