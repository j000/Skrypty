#!/usr/bin/env python3
# -*- coding: utf -8-*-
# Jarosław Rymut

# https://web.archive.org/web/20190212194042if_/http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf

import math
import sys
from time import sleep, time

N = 10
dt = 0.1
anim_len = 5
iterations = 4
diff = 0.001
visc = 0.0001
filename = 'out.mkv'

def clamp(x, low, high):
    if x < low:
        return low
    elif x > high:
        return high
    else:
        return x


def set_bound(b, x):
    x[0, :] = -x[1, :] if b == 1 else x[1, :]
    x[-1, :] = -x[-2, :] if b == 1 else x[-2, :]
    x[:, 0] = -x[:, 1] if b == 2 else x[:, 1]
    x[:, -1] = -x[:, -2] if b == 2 else x[:, -2]

    x[0, 0] = 0.5 * (x[1, 0] + x[0, 1])
    x[0, -1] = 0.5 * (x[1, -1] + x[0, -2])
    x[-1, 0] = 0.5 * (x[-2, 0] + x[-1, 1])
    x[-1, -1] = 0.5 * (x[-2, -1] + x[-1, -2])


def lin_solve(b, x, x0, a, c):
    c = 1.0 / c
    for k in range(iterations):
        for i in range(1, N + 1):
            for j in range(1, N + 1):
                x[i, j] = c * (x0[i, j] + a * (
                    x[i - 1, j] + x[i + 1, j] + x[i, j - 1] + x[i, j + 1]
                ))
        set_bound(b, x)


def diffuse(b, x, x0, diff):
    a = dt * diff * N * N
    lin_solve(b, x, x0, a, 1 + 4 * a)


def advect(b, d, d0, u, v):
    dt0 = dt * N
    for i in range(1, N + 1):
        for j in range(1, N + 1):
            x = i - dt0 * u[i, j]
            x = clamp(x, 0.5, N + 0.5)
            i0 = math.floor(x)
            i1 = i0 + 1
            s1 = x - i0  # float part
            s0 = 1 - s1

            y = j - dt0 * v[i, j]
            y = clamp(y, 0.5, N + 0.5)
            j0 = math.floor(y)
            j1 = j0 + 1
            t1 = y - j0  # float part
            t0 = 1 - t1

            d[i, j] = s0 * (t0 * d0[i0, j0] + t1 * d0[i0, j1]) + \
                s1 * (t0 * d0[i1, j0] + t1 * d0[i1, j1])
    set_bound(b, d)


def project(u, v, p, div):
    div[1:-1, 1:-1] = -0.5 / N * (
            u[2:, 1:-1] - u[:-2, 1:-1]
            + v[1:-1, 2:] - v[1:-1, :-2]
    )
    set_bound(0, div)

    p = np.zeros_like(div)

    lin_solve(0, p, div, 1, 4)

    u[1:-1, :] -= 0.5 * N * (p[2:, :] - p[:-2, :])
    v[:, 1:-1] -= 0.5 * N * (p[:, 2:] - p[:, :-2])
    set_bound(1, u)
    set_bound(2, v)


def vel_step(u, v, u0, v0, visc):
    u += dt * u0
    v += dt * v0
    diffuse(1, u0, u, visc)
    diffuse(2, v0, v, visc)
    project(u0, v0, u, v)
    advect(1, u, u0, u0, v0)
    advect(2, v, v0, u0, v0)
    project(u, v, u0, v0)


def dens_step(x, x0, u, v, diff):
    # x += dt * x0
    diffuse(0, x0, x, diff)
    advect(0, x, x0, u, v)


def convertArgparseMessages(s):
    trans = {
        'usage: ': 'użycie: ',
        'positional arguments': 'Argumenty',
        'optional arguments': 'Argumenty opcjonalne',
        'show this help message and exit': 'pokaż tę wiadomość i wyjdź',
        'unrecognized arguments: %s': 'nierozpoznane argumenty: %s',
        '%(prog)s: error: %(message)s\n': '%(prog)s: błąd: %(message)s\n',
        'expected one argument': 'wymagany argument',
        'expected at most one argument':
            'wymagany nie więcej niż jeden argument',
        'expected at least one argument':
            'wymagany przynajmniej jeden argument',
        'invalid %(type)s value: %(value)r':
            'niepoprawna wartość %(type)s: %(value)r',
        'can\'t open \'%(filename)s\': %(error)s':
            'nie można otworzyć \'%(filename)s\': %(error)s',
    }
    if s in trans:
        return trans[s]
    # print('? >' + s + '<')
    return s


def non_negative_float(value):
    try:
        fvalue = float(value)
        if fvalue >= 0:
            return fvalue
    except:
        pass
    raise argparse.ArgumentTypeError(
        "{:s} nie jest liczbą dodatnią".format(value)
    )


def positive_float(value):
    try:
        fvalue = float(value)
        if fvalue > 0:
            return fvalue
    except:
        pass
    raise argparse.ArgumentTypeError(
        "{:s} nie jest liczbą nieujemną".format(value)
    )


def positive_int(value):
    try:
        fvalue = int(value)
        if fvalue > 0:
            return fvalue
    except:
        pass
    raise argparse.ArgumentTypeError(
        "{:s} nie jest liczbą naturalną".format(value)
    )


def environment():
    u[2, 2] += 4
    v[2, 2] += 2
    v[2, 3] += 2
    dens[2, 2] += 10


if __name__ == '__main__':
    import gettext
    gettext.gettext = convertArgparseMessages
    import argparse
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='''
Symulacja płynów

Symulacja płynów oparta o siatkę. Program wyświetla animację gęstości płynu
oraz prędkości w kierunku poziomym i pionowym.
https://web.archive.org/web/20190212194042if_/http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf

Program spróbuje wyświetlić okno i prowadzi symulację bez końca. Animację można
zapisać do pliku wykorzystując opcję --save.

Do działania program wymaga NumPy i MatPlotLib:
apt-get install python3-matplotlib
albo:
pip install numpy
pip install matplotlib
''',
        epilog='Jarosław Rymut, 2020'
    )
    parser.add_argument(
        '--size',
        '-s',
        metavar='N',
        type=positive_int,
        default=N,
        help='rozmiar siatki symulacji (domyślnie '+str(N)+')'
    )
    parser.add_argument(
        '--deltat',
        '--dt',
        '-t',
        metavar='F',
        type=positive_float,
        default=dt,
        dest='dt',
        help='delta t - zmiana czasu na krok symulacji (domyslnie '+str(dt)+')'
    )
    parser.add_argument(
        '--diffusion',
        '--diff',
        '-d',
        metavar='F',
        type=non_negative_float,
        default=diff,
        dest='diff',
        help='współczynnik dyfuzji (domyślnie '+str(diff)+') - odpowiada \
            za "rozlewanie" się wartości na sąsiednie komórki'
    )
    parser.add_argument(
        '--viscosity',
        '--visc',
        '-v',
        metavar='F',
        type=non_negative_float,
        default=visc,
        dest='visc',
        help='współczynnik lepkości cieczy (domyślnie '+str(visc)+')'
    )
    parser.add_argument(
        '--save',
        metavar='FILE',
        nargs='?',
        const=filename,
        dest='filename',
        help='nazwa pliku do zapisania animacji, jeśli program nie ma działać \
            w trybie interaktywnym'
    )
    parser.add_argument(
        '--len',
        '-l',
        metavar='F',
        type=positive_float,
        default=anim_len,
        help='czas trwania symulacji - przy zapisie do pliku'
    )
    args = parser.parse_args()

    try:
        import numpy as np
        import matplotlib
        import matplotlib.pyplot as plt
        import matplotlib.animation as animation
    except ModuleNotFoundError as mnfe:
        print('Moduł ' + str(mnfe.name) + ' nie został znaleziony, ' +
            'ale jest wymagany. Zapoznaj się z pomocą')
        exit(1)

    N = args.size
    dt = args.dt
    anim_len = args.len
    filename = args.filename

    if filename:
        import mimetypes
        mimetypes.init()
        mimestart = mimetypes.guess_type(filename)[0]
        if mimestart == None or mimestart.split('/')[0] != 'video':
            filename += '.mkv'

    diff = args.diff
    visc = args.visc

    u = np.zeros((N + 2, N + 2))
    v = np.zeros((N + 2, N + 2))
    u_prev = np.zeros((N + 2, N + 2))
    v_prev = np.zeros((N + 2, N + 2))
    dens = np.zeros((N + 2, N + 2))
    dens_prev = np.zeros((N + 2, N + 2))

    environment()

    fig = plt.figure(dpi=100)
    fig.set_size_inches(19.2, 10.8)
    gs = fig.add_gridspec(2, 5)
    ax0 = fig.add_subplot(gs[:, :2])
    ax1 = fig.add_subplot(gs[0, 2])
    ax2 = fig.add_subplot(gs[1, 2])
    ax3 = fig.add_subplot(gs[:, 3:])
    for i in (ax0, ax1, ax2, ax3):
        i.axis(xmin=0.5, xmax=N + 0.5, ymin=0.5, ymax=N + 0.5)
        i.set_axis_off()
    ax0.set_title('gęstość')
    ax1.set_title('wartość prędkości w kierunku pionowym')
    ax2.set_title('wartość prędkości w kierunku poziomym')
    ax3.set_title('wartość prędkości')
    g0 = ax0.imshow(dens, interpolation='bicubic', cmap='cividis', animated=True)
    g1 = ax1.imshow(u[1:-1, 1:-1], interpolation='bicubic', cmap='plasma', animated=True)
    g2 = ax2.imshow(v[1:-1, 1:-1], interpolation='bicubic', cmap='plasma', animated=True)
    g3 = ax3.quiver(u[1:-1, 1:-1], v[1:-1, 1:-1], animated=True, scale=5, angles='xy', pivot='mid')
    fig.tight_layout()

    def animate(frame):
        global u, v, u_prev, v_prev, dens, dens_prev

        fig.suptitle("Frame " + str(frame))

        environment()

        vel_step(u, v, u_prev, v_prev, visc)
        dens_step(dens, dens_prev, u, v, diff)

        g0.set_array(dens)
        g1.set_array(u[1:-1, 1:-1])
        g2.set_array(v[1:-1, 1:-1])
        g3.set_UVC(u[1:-1, 1:-1], v[1:-1, 1:-1])

        # bo animacja tego nie robi
        g0.norm.vmax = np.amax(dens[1:-1, 1:-1])
        g0.norm.vmin = np.amin(dens[1:-1, 1:-1])
        g1.norm.vmax = np.amax(u[1:-1, 1:-1])
        g1.norm.vmin = np.amin(u[1:-1, 1:-1])
        g2.norm.vmax = np.amax(v[1:-1, 1:-1])
        g2.norm.vmin = np.amin(v[1:-1, 1:-1])
        if filename:
            print("\033[1AKlatka {} / {} ({:.2f}s / {:.2f}s)".format(
                frame, int(anim_len / dt), frame * dt, anim_len
            ))

    anim = animation.FuncAnimation(fig, animate, interval=64, blit=False)
    if filename is None:
        start = time()
        plt.show()
        end = time()
        if (end - start < 0.1):
            print('Matplotlib nie potrafił wyświetlić okna.')
            filename = 'out.mkv'
    if filename:
        from subprocess import CalledProcessError
        print('Zapisuję {}-sekundową animację do pliku {}\n'.format(
            anim_len, filename
        ))
        anim.save_count = max(1, int(anim_len / dt))
        try:
            anim.save(filename, fps=max(math.floor(1. / dt), 1))
        except (KeyboardInterrupt, CalledProcessError):
            pass

else:
    import numpy as np
    import matplotlib.pyplot as plt
    import matplotlib.animation as animation
